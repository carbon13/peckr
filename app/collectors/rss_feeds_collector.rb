# encoding: utf-8
class RssFeedsCollector
  def query_and_store
    self.store(self.query)
    self.store_bodies(self.query_bodies)
  end

  def query
    parsed_results = {}
    target_uris = RssSource.all.pluck(:link)
    target_uris.each do |uri|
      parsed_results.store(uri, Nokogiri::XML(open(uri, redirect: true)))
    end
    parsed_results
  end

  def store(results)
    return if results.nil?
    results.each do |rss_source_link, result|
      result.xpath('//channel').each do |node|
        rss_source = RssSource.find_by(link: rss_source_link)
        rss_source.title = node.xpath('./title').first.try(:text)
        # FIXME: Undefined namespace prefix 'atom:'; rss_source.atom_link = node.xpath('./atom:link').attribute('href').first.try(:value)
        rss_source.description = node.xpath('./description').first.try(:text)
        rss_source.last_build_date = Time.rfc2822(node.xpath('./lastBuildDate').first.try(:text))
        rss_source.language = node.xpath('./language').first.try(:text)
        rss_source.generator = node.xpath('./generatorTime').first.try(:text)
        rss_source.save
      end
      result.xpath('//item').each do |node|
        unless RssFeed.find_by(title: node.xpath('.//title').try(:text))
          rss_feed = RssFeed.new
          rss_feed.title = node.xpath('.//title').try(:text)
          rss_feed.description = node.xpath('.//description').try(:text)
          rss_feed.link = node.xpath('.//link').try(:text)
          rss_feed.pubdate = Time.rfc2822(node.xpath('.//pubDate').try(:text))
          rss_feed.save 
        end
      end
    end
  end

  def query_bodies
    parsed_results = {}
    target_rss_feeds = RssFeed.has_no_body
    return unless target_rss_feeds.exists?
    target_rss_feeds.each do |target_rss_feed|
      parsed_body = Nokogiri::HTML.parse(open(target_rss_feed.link, redirect: true))
      parsed_results.store(target_rss_feed.id, parsed_body)
    end
    return parsed_results
  end

  def store_bodies(results)
    return if results.nil?
    results.each do |rss_feed_id, result|
      trimed_body = result.xpath('//body').inner_text.gsub(/^[\s　]+|[\s　]+$/, "").gsub(/(\r\n|\r|\n)/, ' ')
      rss_feed = RssBody.new(rss_feed_id: rss_feed_id, body: trimed_body)
      rss_feed.save
    end
  end

  def exclude_tags(result, additional_exclusive_tag_names=[])
    exclusive_tag_names = ['script', 'head'].concat(additional_exclusive_tag_names)
    exclusive_tag_names.each do |tag_name|
      result.root.xpath("//#{tag_name}").each { |node| node.remove }
    end
    return result
  end
end