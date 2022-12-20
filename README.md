# Wordpress to markdown

Export method described [here](https://daext.com/blog/convert-wordpress-articles-to-markdown/).

``` shell
node -v
npx wordpress-export-to-markdown
```

Then answer questions such as:

``` shell
Starting wizard...
? Path to WordPress export file? atlantis.WordPress.2022-12-20.xml
? Path to output folder? output
? Create year folders? No
? Create month folders? No
? Create a folder for each post? Yes
? Prefix post folders/files with date? No
? Save images attached to posts? Yes
? Save images scraped from post body content? Yes
? Include custom post types and pages? No

Parsing...
1 posts found.
0 attached images found.
1 images scraped from post body content.

Saving 1 posts (0 already exist)...
[OK] jane-s-infinite-rosary
Done, got them all!
```
