export default class Cookies {
  static getCookie(name: string) {
    let cookies = document.cookie.split(";");
    let kvp: [string, string][] = cookies.map(cookie => cookie.split("=") as [string, string]);

    for (let [k, v] of kvp) {
      if (k == name) return v;
    }

    return undefined;
  }

  static setCookie(name: string, value: any) {
    if (document.cookie == "") document.cookie = name + "=" + value;

    let cookies = document.cookie.split(";");
    let kvp: [string, string][] = cookies.map(cookie => cookie.split("=") as [string, string]);

    for (let [k, v] of kvp) {
      if (k == name) {
        document.cookie.replace(k + "=" + v, name + "=" + value);
        return;
      }
    }

    document.cookie += ";" + name + "=" + value;
  }

  static setExpiration(days: number) {
    const d = new Date();
    d.setTime(d.getTime() + (days * 24 * 60 * 60 * 1000));
    Cookies.setCookie("expires", d.toUTCString());
  }
};
