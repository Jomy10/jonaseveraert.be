require 'rmagick'
require 'pg'
require 'json'

IMG_OG_PATH="assets/images/original"
IMG_GALLERY_PATH="assets/images/gallery"
IMG_FULLSCREEN_PATH="assets/images/fullscreen"

# Process new images in the assets/images/original folder
def process_images(pgconn)
  for file in Dir[File.join(IMG_OG_PATH, "*")]
    filename = File.basename(file)
    basename = File.basename(file, File.extname(file))

    check_img_sql = <<-SQL
      select EXISTS(select 1 from Image where FileName = $1)
      SQL
    exists_res = pgconn.exec_params check_img_sql, [basename]
    exists = exists_res.first["exists"] == "t"
    next if exists

    json_file = basename + ".json"
    json = nil
    if File.exist?(json_file)
      json = JSON.parse(json_file)
    end

    process_image(filename, pgconn, json)
  end
end

# Process image
def process_image(image_file, pgconn, img_meta)
  puts "Processing #{image_file}"
  img = Magick::Image.read(File.join(IMG_OG_PATH, image_file)).first
  img_name = File.basename(image_file, File.extname(image_file))
  image_to_gallery_thumbnail(img.clone, img_name)
  image_to_fullscreen(img.clone, img_name)

  new_img_sql = <<-SQL
    insert into Image (FileName, Category, Series)
    values (
      $1,
      $2,
      $3
    );
    SQL
  pgconn.exec_params new_img_sql, [img_name, img_meta.nil? ? nil : img_meta["category"], img_meta.nil? ? nil : img_meta["series"]]
end

def image_to_gallery_thumbnail(image, image_name)
  thumbnail_max_width = 387
  ext = ".webp"
  img_w = image.columns
  img_h = image.rows
  if img_w > thumbnail_max_width
    scaling = thumbnail_max_width.to_f / img_w.to_f
    image = image.resize(thumbnail_max_width, img_h * scaling)
  end
  image.write(File.join(IMG_GALLERY_PATH, image_name + ext)) { |options|
    options.quality = 50
  }
end

def image_to_fullscreen(image, image_name)
  max_width = 1000
  ext = ".webp"
  img_w = image.columns
  img_h = image.rows
  if img_w > max_width
    scaling = max_width.to_f / img_w.to_f
    image = image.resize(max_width, img_h * scaling)
  end
  image.write(File.join(IMG_FULLSCREEN_PATH, image_name + ext)) { |options|
    options.quality = 85
  }
end
