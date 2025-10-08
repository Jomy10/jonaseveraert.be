CREATE TABLE "Image" (
	"Id" serial PRIMARY KEY NOT NULL,
	"FileName" text NOT NULL,
	"CreatedDate" date DEFAULT now() NOT NULL,
	CONSTRAINT "Image_FileName_unique" UNIQUE("FileName")
);
--> statement-breakpoint
CREATE TABLE "User" (
	"UserName" text PRIMARY KEY NOT NULL,
	"PassWord" text NOT NULL,
	"CreatedDate" date DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE INDEX "Image_date_index" ON "Image" USING btree ("CreatedDate");