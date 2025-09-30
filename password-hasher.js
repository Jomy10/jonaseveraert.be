import bcrypt from "bcrypt";

async function hashPassword(password) {
  const saltRounds = 15;
  const hashedPassword = await bcrypt.hash(password, saltRounds);
  return hashedPassword;
}

const passwd = process.argv[2];
console.log(passwd, "->", await hashPassword(passwd));
