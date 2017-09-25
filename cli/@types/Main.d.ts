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
