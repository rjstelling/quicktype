type Json = object;
type IRTypeable = Json | string;

declare module "Config" {
  export type TopLevelConfig =
    | { name: string; samples: IRTypeable[] }
    | { name: string; schema: Json };

  export interface Config {
    language: string;
    topLevels: TopLevelConfig[];
    rendererOptions?: { [name: string]: string };
  }
}

declare module "Data.Either" {
  export type Either<L, R> = { value0: L | R };

  export function isRight<T, U>(either: Either<T, U>): boolean;
  export function isLeft<T, U>(either: Either<T, U>): boolean;
  export function fromRight<T>(either: Either<string, T>): T;
}

declare module "Data.Maybe" {
  export type Maybe<T> = { value0?: T };

  export function isJust<T>(maybe: Maybe<T>): boolean;
  export function fromJust<T>(maybe: Maybe<T>): T;
}

declare module "Options" {
  export interface OptionSpecification {
    name: string;
    description: string;
    typeLabel: string;
  }
}

declare module "Doc" {
  import { OptionSpecification } from "Options";

  export interface Renderer {
    displayName: string;
    names: [string];
    extension: string;
    aceMode: string;
    options: [OptionSpecification];
  }
}

declare module "Language.Renderers" {
  import { Renderer } from "Doc";
  import { Maybe } from "Data.Maybe";

  export const all: Renderer[];
  export function rendererForLanguage(language: string): Maybe<Renderer>;
}

type SourceCode = string;
type ErrorMessage = string;

declare module "Main" {
  import { Config } from "Config";
  import { Either } from "Data.Either";

  export function main(config: Config): Either<ErrorMessage, SourceCode>;

  export function mainWithOptions(options: {
    [name: string]: string;
  }): ((config: Config) => Either<ErrorMessage, SourceCode>);

  export function urlsFromJsonGrammar(
    json: object
  ): Either<string, { [key: string]: string[] }>;

  export const intSentinel: string;
}
