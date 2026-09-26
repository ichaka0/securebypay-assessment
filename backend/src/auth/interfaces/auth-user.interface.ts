/** Claims encoded in the access token. */
export interface JwtPayload {
  sub: string;
  email: string;
}

/** User identity attached to `request.user` after JWT validation. */
export interface AuthUser {
  id: string;
  email: string;
}
