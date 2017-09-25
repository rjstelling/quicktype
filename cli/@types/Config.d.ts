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
