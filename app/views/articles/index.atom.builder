atom_feed :language => 'en-us', :root_url => articles_url do |feed|
  feed.title %|Srikanth's Articles|
  feed.subtitle 'Everything from cricket to programming'
  feed.updated @articles.first[:time]
  feed.author do |author|
    author.name 'Srikanth Agaram'
    author.url root_url
  end
  feed.icon asset_path('favicon.png')
  feed.rights 'copyright 2005-2009 Srikanth Agaram'

  @articles.each do |article|
    feed.entry(
      article,
      :id => "article#{article[:id]}",
      :url => article_url(article[:id]),
      :updated => article[:time]
    ) do |entry|

      entry.title article[:title]

      entry.summary :type => 'xhtml' do |xhtml|
        xhtml.p article[:snippet]
        xhtml.a 'read full article', :href => article_url(article[:id])
      end

      entry.link :rel => 'alternate', :href => article_url(article[:id])

      entry.author do |author|
        author.name 'Srikanth Agaram'
        author.url root_url
      end

    end
  end
end
