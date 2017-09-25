declare module "Data.Maybe" {
  export type Maybe<T> = { value0?: T };

  export function isJust<T>(maybe: Maybe<T>): boolean;
  export function fromJust<T>(maybe: Maybe<T>): T;
}
