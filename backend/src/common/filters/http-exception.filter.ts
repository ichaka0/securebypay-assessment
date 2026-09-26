import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import { Request, Response } from 'express';

/** Shape of every error response returned by the API. */
export interface ErrorResponseBody {
  statusCode: number;
  error: string;
  /** Human-readable summary suitable for showing in a toast/snackbar. */
  message: string;
  /** Per-field validation messages, when the request body was invalid. */
  errors?: Record<string, string[]>;
  path: string;
  timestamp: string;
}

/**
 * Normalises all thrown errors into {@link ErrorResponseBody} so the client
 * has one predictable shape to parse. Unknown errors become 500s and are
 * logged without leaking internals to the caller.
 */
@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  private readonly logger = new Logger(AllExceptionsFilter.name);

  catch(exception: unknown, host: ArgumentsHost): void {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();

    let status = HttpStatus.INTERNAL_SERVER_ERROR;
    let message = 'Something went wrong. Please try again.';
    let errors: Record<string, string[]> | undefined;

    if (exception instanceof HttpException) {
      status = exception.getStatus();
      const res = exception.getResponse();
      if (typeof res === 'string') {
        message = res;
      } else {
        const body = res as {
          message?: string | string[];
          errors?: Record<string, string[]>;
        };
        errors = body.errors;
        if (Array.isArray(body.message)) {
          message = body.message[0] ?? message;
        } else if (body.message) {
          message = body.message;
        }
      }
    } else {
      this.logger.error(exception);
    }

    const payload: ErrorResponseBody = {
      statusCode: status,
      error: HttpStatus[status] ?? 'ERROR',
      message,
      ...(errors ? { errors } : {}),
      path: request.url,
      timestamp: new Date().toISOString(),
    };
    response.status(status).json(payload);
  }
}
