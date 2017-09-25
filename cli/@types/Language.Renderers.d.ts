import { Renderer } from "Doc";
import { Maybe } from "Data.Maybe";

declare module "Language.Renderers" {
  export const all: Renderer[];
  export function rendererForLanguage(language: string): Maybe<Renderer>;
}
