atom_feed :language => 'en-us', :root_url => articles_url do |feed|
  feed.title "Srikanth's Articles"
  feed.subtitle "Everything from cricket to programming"
  feed.updated @articles.first[:time]
  feed.author do |author|
    author.name 'Srikanth Agaram'
    author.url home_url
  end
  feed.icon '/images/favicon.png'
  feed.rights 'copyright 2005-2009 Srikanth Agaram'

  @articles.each do |article|
    feed.entry(
      article,
      :id => "article#{article[:id]}",
      :url => article_path(article[:id]),
      :updated => article[:time]
    ) do |entry|

      entry.title article[:title]

      entry.summary :type => 'xhtml' do |xhtml|
        xhtml.p article[:snippet]
        xhtml.a 'read full article', :href => article_path(article[:id])
      end

      entry.link :rel => 'alternate', :href => article_path(article[:id])

      entry.author do |author|
        author.name 'Srikanth Agaram'
        author.url home_url
      end

    end
  end
end
