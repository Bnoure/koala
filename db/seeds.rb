require 'news-api'
require 'openai'

User.destroy_all
Post.destroy_all
Comment.destroy_all

client = OpenAI::Client.new

user1 = User.create!(email: "nour@mail.com", password: "test123", nickname: "bnoure")
user1.avatar.attach(io: File.open(Rails.root.join('app', 'assets', 'images', 'avatar-item2.png')), filename: 'avatar-item2.png', content_type: 'image/png')

user2 = User.create!(email: "zoe@mail.com", password: "test123", nickname: "zoe")
user2.avatar.attach(io: File.open(Rails.root.join('app', 'assets', 'images', 'avatar-item.png')), filename: 'avatar-item.png', content_type: 'image/png')

user3 = User.create!(email: "marc@mail.com", password: "test123", nickname: "marc")
user3.avatar.attach(io: File.open(Rails.root.join('app', 'assets', 'images', 'avatar-item3.png')), filename: 'avatar-item3.png', content_type: 'image/png')

users = [user1, user2, user3]

newsapi = News.new("9eefa0be543a4d3f95933e58984e32d6")
all_articles = newsapi.get_everything(q: 'tourisme',
                                      language: 'fr',
                                      sortBy: 'relevancy',
                                      excludeDomains: 'en.wikipedia.org')

all_articles.sample(25).each do |article|
  article.title = "Titre par défaut" if article.title.blank?
  article.content = "Contenu par défaut" if article.content.blank?

  response = client.chat(
    parameters: {
      model: "gpt-3.5-turbo-0301",
      messages: [
        { role: "system", content: "Tu es un journaliste ." },
        { role: "user", content: "Title: #{article.title}\nContent: #{article.content}\n\nContinue l'article avec 2000 caractères pile :" }
      ],
      temperature: 0.5,
      max_tokens: 800
    }
  )
  generated_text = response['choices'].first['message']['content']

  response_short = client.chat(
    parameters: {
      model: "gpt-3.5-turbo-0301",
      messages: [
        { role: "system", content: "Tu es un journaliste" },
        { role: "user", content: "Title: #{article.title}\nContent: #{article.content}\n\nRésume l'article en 20 mots:" }
      ],
      temperature: 0.5,
      max_tokens: 100
    }
  )
  short_description = response_short['choices'].first['message']['content']

  post = Post.new(title: article.title, content: article.content, description: generated_text, url: article.url, urlI: article.urlToImage, user: users.sample , short: short_description )
  post.image.attach(io: URI.open(article.urlToImage), filename: 'image.jpg', content_type: 'image/jpg') if article.urlToImage.present?

  if post.save
    puts "Post created successfully"
  else
    puts "Failed to create post: #{post.errors.full_messages.join(", ")}"
  end
end
