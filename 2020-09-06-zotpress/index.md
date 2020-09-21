---
title: "Zotpress"
date: "2020-09-06"
---

![](https://blog.atlant.is/wp-content/uploads/2020/09/zotpress.png)

A useful plugin by [Katie Seaborn](http://katieseaborn.com/) to manage bibliography for your articles: brings Zotero and scholarly blogging to your WordPress website.

There is a small glitch with [version](https://plugins.trac.wordpress.org/changeset/2169267/zotpress) [7.1.5](https://plugins.trac.wordpress.org/changeset/2375593/zotpress) and WordPress Twenty Twenty theme: the bibliography block is flushed to the left instead of being aligned with the other blocks.

Enjoy this [quick hack](https://plugins.trac.wordpress.org/ticket/2905):

\--- lib/shortcode/shortcode.intextbib.php.orig	2020-09-02 17:58:58.000000000 +0200
+++ lib/shortcode/shortcode.intextbib.php	2020-09-02 18:00:02.000000000 +0200
@@ -132,7 +132,7 @@
 
 
     // GENERATE IN-TEXT BIB STRUCTURE
-	$zp\_output = "\\n<div id='zp-InTextBib-".$instance\_id."' class='zp-Zotpress zp-Zotpress-InTextBib";
+	$zp\_output = "\\n<div id='zp-InTextBib-".$instance\_id."' class='zp-Zotpress zp-Zotpress-InTextBib' style='margin: 0 auto;'";
 	if ( $forcenumber ) $zp\_output .= " forcenumber";
 	$zp\_output .= " zp-Post-".get\_the\_ID()."'>";
 	$zp\_output .= '

Update: [version 7.1.6](https://plugins.trac.wordpress.org/changeset/2375593/zotpress) provides a clean fix for the problem.
