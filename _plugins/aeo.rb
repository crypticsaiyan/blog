# Search / answer-engine helpers:
#   1. posts without `description:` / `image:` front matter get them from the
#      first prose paragraph / first image, so share cards and jekyll-seo-tag
#      have something better than the site-wide defaults
#   2. /llms.txt (index) and /llms-full.txt (every post as markdown), see
#      https://llmstxt.org

module Blog
  module Aeo
    DESCRIPTION_LENGTH = 160

    # Plain text of the first real paragraph: skips headings, images, code,
    # quotes, lists and tables, then strips inline markdown.
    def self.first_paragraph(markdown)
      in_code = false
      markdown.split(/\n\s*\n/).each do |block|
        block = block.strip
        # fenced code can contain blank lines, so track open/close across blocks
        was_in_code = in_code
        in_code = !in_code if block.scan(/^```/).length.odd?
        next if was_in_code || in_code || block.empty? || block.start_with?("```")
        next if block.match?(/\A(#|!\[|>|\||[-*+] |\d+\. |\{%|<)/)

        text = block
          .gsub(/!\[[^\]]*\]\([^)]*\)/, "")
          .gsub(/\[([^\]]*)\]\([^)]*\)/, '\1')
          .gsub(/[*_`~]+/, "")
          .gsub(/\s+/, " ")
          .strip
        return text unless text.empty?
      end
      nil
    end

    def self.truncate(text, length)
      return text if text.length <= length

      text[0, length].sub(/\s+\S*\z/, "").sub(/[\s.,;:!?]+\z/, "") + "…"
    end

    def self.first_image(markdown)
      markdown[/!\[[^\]]*\]\(\s*([^)\s]+)/, 1]
    end

    # Root-relative links/images -> absolute, so the markdown works off-site
    def self.absolutize(markdown, site_url)
      markdown.gsub(/(\]\()\//, "\\1#{site_url}/")
    end
  end

  class AeoGenerator < Jekyll::Generator
    safe true
    # before jekyll-feed, so the feed sees the generated descriptions too
    priority :highest

    def generate(site)
      posts = site.posts.docs.reverse
      posts.each { |post| fill_defaults(post) }

      site.pages << text_page(site, "llms.txt", llms_txt(site, posts))
      site.pages << text_page(site, "llms-full.txt", llms_full_txt(site, posts))
    end

    private

    def fill_defaults(post)
      if post.data["description"].to_s.strip.empty?
        paragraph = Aeo.first_paragraph(post.content)
        post.data["description"] = Aeo.truncate(paragraph, Aeo::DESCRIPTION_LENGTH) if paragraph
      end

      # front-matter defaults set the site-wide og image; a post's own first
      # image is a better preview
      default_image = post.site.frontmatter_defaults.find(post.relative_path, :posts, "image")
      if post.data["image"].nil? || post.data["image"] == default_image
        image = Aeo.first_image(post.content)
        post.data["image"] = image if image
      end
    end

    def text_page(site, name, content)
      page = Jekyll::PageWithoutAFile.new(site, site.source, "", name)
      page.content = content
      # post bodies may contain {{ }} / {% %} in code samples
      page.data["render_with_liquid"] = false
      page.data["layout"] = nil
      page.data["sitemap"] = false
      page
    end

    def site_url(site)
      site.config["url"].to_s.chomp("/")
    end

    def llms_txt(site, posts)
      url = site_url(site)
      author = site.config["author"] || {}
      lines = []
      lines << "# #{site.config['title']}"
      lines << ""
      lines << "> #{site.config['description']}"
      lines << ""
      lines << site.config["about"].to_s if site.config["about"]
      lines << "Author: #{author['name']} (#{author['url']})" if author["name"]
      lines << ""
      lines << "## Posts"
      lines << ""
      posts.each do |post|
        entry = "- [#{post.data['title']}](#{url}#{post.url})"
        entry += ": #{post.data['description']}" if post.data["description"]
        lines << entry
      end
      lines << ""
      lines << "## Optional"
      lines << ""
      lines << "- [All posts as markdown](#{url}/llms-full.txt)"
      lines << "- [RSS feed](#{url}/feed.xml)"
      lines << "- [Author's portfolio](#{author['url']}/llms.txt)" if author["url"]
      lines.join("\n") + "\n"
    end

    def llms_full_txt(site, posts)
      url = site_url(site)
      header = "# #{site.config['title']}\n\n> #{site.config['description']}\n\n#{site.config['about']}\n"
      bodies = posts.map do |post|
        <<~POST
          # #{post.data['title']}

          URL: #{url}#{post.url}
          Published: #{post.date.strftime('%Y-%m-%d')}

          #{Aeo.absolutize(post.content.strip, url)}
        POST
      end
      ([header] + bodies).join("\n---\n\n")
    end
  end
end
