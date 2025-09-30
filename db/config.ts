import { defineDb, defineTable, column, NOW } from 'astro:db';

// Gallery //
const Image = defineTable({
  columns: {
    Id: column.number({ primaryKey: true }),
    FileName: column.text({ unique: true }),
    // Category, Series
    CreatedDate: column.date({ default: NOW })
  },
  indexes: [
    { on: "CreatedDate" }
  ]
});

// Authentication //
const User = defineTable({
  columns: {
    UserName: column.text({ primaryKey: true }),
    PassWord: column.text(),
    CreatedDate: column.date({ default: NOW }),
  }
});

// https://astro.build/db/config
export default defineDb({
  tables: {
    Image,
    User,
  }
});
