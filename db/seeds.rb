require 'news-api'
require 'openai'

User.destroy_all
Post.destroy_all
Comment.destroy_all

comment_contents = [
  "Super article, très informatif!",
  "J'ai vraiment apprécié la lecture de cet article.",
  "Merci pour ces informations précieuses.",
  "Très intéressant, j'ai hâte de lire le prochain article!",
  "Cet article m'a vraiment aidé à comprendre le sujet.",
  "Excellent travail, continuez comme ça!",
  "J'ai appris beaucoup de choses grâce à cet article.",
  "Cet article est très bien écrit, bravo!",
  "Je recommande cet article à tous ceux qui s'intéressent à ce sujet.",
  "Cet article est une excellente ressource pour ceux qui veulent en savoir plus sur ce sujet."
]

image_errors = ["forest.jpg","forest2.jpg","forest3.jpg"]

client = OpenAI::Client.new

user1 = User.create!(email: "nour@mail.com", password: "test123", nickname: "bnoure")
user1.avatar.attach(io: File.open(Rails.root.join('app', 'assets', 'images', 'av1.jpg')), filename: 'av1.jpg', content_type: 'image/png')

user2 = User.create!(email: "zoe@mail.com", password: "test123", nickname: "zoe")
user2.avatar.attach(io: File.open(Rails.root.join('app', 'assets', 'images', 'av2.jpg')), filename: 'av2.jpg', content_type: 'image/png')

user3 = User.create!(email: "marc@mail.com", password: "test123", nickname: "marc")
user3.avatar.attach(io: File.open(Rails.root.join('app', 'assets', 'images', 'av3.jpg')), filename: 'av3.jpg', content_type: 'image/png')

users = [user1, user2, user3]

newsapi = News.new("9eefa0be543a4d3f95933e58984e32d6")
all_articles = newsapi.get_everything(q: 'tourisme',
                                      language: 'fr',
                                      sortBy: 'relevancy',
                                      excludeDomains: 'en.wikipedia.org')

all_articles.sample(25).each do |article|
  article.title = "Titre par défaut" if article.title.blank?
  article.content = "Contenu par défaut" if article.content.blank?

   # Vérifie si le titre est vide et le remplace par une valeur générée par GPT-3
   if article.title.blank?
    response_title = client.chat(
      parameters: {
        model: "gpt-3.5-turbo-0301",
        messages: [
          { role: "system", content: "Tu es un journaliste." },
          { role: "user", content: "Content: #{article['content']}\n\nCrée un titre pour cet article:" }
        ],
        temperature: 0.5,
        max_tokens: 60
      }
    )
    article.title = response_title['choices'].first['message']['content']
  end

  response = client.chat(
    parameters: {
      model: "gpt-3.5-turbo-0301",
      messages: [
        { role: "system", content: "Tu es un journaliste." },
        { role: "user", content: "Title: #{article.title}\nContent: #{article.content}\n\nContinue l'article avec 2000 caractères pile:" }
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

  post = Post.new(title: article.title, content: article.content, description: generated_text, url: article.url, urlI: article.urlToImage, user: users.sample, short: short_description)

  if article.urlToImage.present?
    uploaded_image = Cloudinary::Uploader.upload(article.urlToImage)
    post.image.attach(io: URI.open(uploaded_image['url']), filename: File.basename(URI.parse(uploaded_image['url']).path))
  else
    default_image = image_errors.sample
    uploaded_image = Cloudinary::Uploader.upload(Rails.root.join('app', 'assets', 'images', default_image))
    post.image.attach(io: URI.open(uploaded_image['url']), filename: File.basename(URI.parse(uploaded_image['url']).path))
  end
  
  if post.save
    puts "Post #{post.id} created successfully"
    if [true, false].sample
      comment_content = comment_contents.sample
      comment = post.comments.create!(
        content: comment_content,
        user: users.sample
      )

      if comment.save
        puts "Comment created successfully for post #{post.id}, #{comment.user.nickname}"

        # 66% de chance de créer un deuxième commentaire
        if [true, true, false].sample
          comment_content = comment_contents.sample
          comment = post.comments.create!(
            content: comment_content,
            user: users.sample
          )

          if comment.save
            puts "Second comment created successfully for post #{post.id}, #{comment.user.nickname}"
          else
            puts "Failed to create second comment for post #{post.id}: #{comment.errors.full_messages.join(", ")}"
          end
        end
      else
        puts "Failed to create comment for post #{post.id}: #{comment.errors.full_messages.join(", ")}"
      end
    end
  end
end
