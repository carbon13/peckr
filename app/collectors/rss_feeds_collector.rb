# encoding: utf-8
class RSSFeedsCollector
  def query_and_store
    store(query)
    store_bodies(query_bodies)
  end

  def query
    parsed_results = {}
    target_uris = RSSSource.all.pluck(:link)
    target_uris.each do |uri|
      parsed_results.store(uri, Nokogiri::XML(open(uri, redirect: true)))
    end
    parsed_results
  end

  def store(results)
    return if results.nil?
    results.each do |rss_source_link, result|
      update_rss_source_info(rss_source_link, result)
      store_rss_feed(result)
    end
  end

  def update_rss_source_info(rss_source_link, result)
    result.xpath('//channel').each do |node|
      rss_source = RSSSource.find_by(link: rss_source_link)
      rss_source.title = node.xpath('./title').first.try(:text)
      # FIXME: Undefined namespace prefix 'atom:'
      #   rss_source.atom_link = node.xpath('./atom:link').attribute('href').first.try(:value)
      rss_source.description = node.xpath('./description').first.try(:text)
      rss_source.last_build_date = Time.rfc2822(node.xpath('./lastBuildDate').first.try(:text))
      rss_source.language = node.xpath('./language').first.try(:text)
      rss_source.generator = node.xpath('./generatorTime').first.try(:text)
      rss_source.save
    end
  end

  def store_rss_feed(result)
    result.xpath('//item').each do |node|
      next if RSSFeed.find_by(title: node.xpath('.//title').try(:text))
      rss_feed = RSSFeed.new
      rss_feed.title = node.xpath('.//title').try(:text)
      rss_feed.description = node.xpath('.//description').try(:text)
      rss_feed.link = node.xpath('.//link').try(:text)
      rss_feed.pubdate = Time.rfc2822(node.xpath('.//pubDate').try(:text))
      rss_feed.save
    end
  end

  def query_bodies
    parsed_results = {}
    target_rss_feeds = RSSFeed.no_body
    return unless target_rss_feeds.exists?
    target_rss_feeds.each do |target_rss_feed|
      parsed_body = Nokogiri::HTML.parse(open(target_rss_feed.link, redirect: true))
      parsed_results.store(target_rss_feed.id, parsed_body)
    end
    parsed_results
  end

  def store_bodies(results)
    return if results.nil?
    results.each do |rss_feed_id, result|
      trimed_body = result.xpath('//body').inner_text.gsub(/^[\s　]+|[\s　]+$/, '').gsub(/(\r\n|\r|\n)/, ' ')
      rss_feed = RSSBody.new(rss_feed_id: rss_feed_id, body: trimed_body)
      rss_feed.save
    end
  end

  def exclude_tags(result, additional_exclusive_tag_names = [])
    exclusive_tag_names = %w(script head).concat(additional_exclusive_tag_names)
    exclusive_tag_names.each do |tag_name|
      result.root.xpath("//#{tag_name}").each { |node| node.remove }
    end
    result
  end
end