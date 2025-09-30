import Cookies from "@lib/cookies";

export type Language = "en" | "nl";

export const langs: Language[] = ["en", "nl"];

export function isValidLanguage(language: string | null): boolean {
  if (language == null) return false;
  return (langs as string[]).includes(language);
}

/// Get the langauge corresponding to the given language,
/// or the default language
export function getLang(language: string | null, acceptLanguageHeader: string | null = null): Language {
  if (isValidLanguage(language))
    return language as Language;
  else
    return getCurrentLanguage(acceptLanguageHeader);
}

export function getCurrentLanguage(acceptLanguageHeader: string | null = null): Language {
  if (import.meta.env.SSR) {
    return (acceptLanguageHeader?.split(";").find(language => isValidLanguage(language.split("-")[0]))?.split("-")[0] || "en") as Language;
  } else {
    const searchParameters = new URLSearchParams(window.location.search);
    const currentLang = searchParameters.get("lang");
    if (currentLang != null && isValidLanguage(currentLang))
      return currentLang as Language;

    if (Cookies.getCookie("lang") != undefined)
      return Cookies.getCookie("lang")! as Language;

    // @ts-ignore
    let userLanguage: string = window.navigator.userLanguage || window.navigator.language;
    userLanguage = userLanguage.split("-")[0];
    if (isValidLanguage(userLanguage))
      return userLanguage as Language;
    else
      return (window.navigator.languages.find(language => isValidLanguage(language.split("-")[0]))?.split("-")[0] || "en") as Language;
  }
}
