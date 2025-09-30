import { getCurrentLanguage, type Language } from "./langs";

export default function createLink(link: string, language: Language | undefined = undefined): string {
  return link + "?lang=" + (language ?? document.querySelector("html")!.lang ?? getCurrentLanguage());
}
