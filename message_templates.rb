def create_flex_message(subscriptions, filter_finish_soon: false)
  filtered_subscriptions = subscriptions

  if filter_finish_soon
    filtered_subscriptions = filtered_subscriptions.select { |sub| sub.finish.present? }
  end

  {
    type: 'flex',
    altText: '映画の情報',
    contents: {
      type: 'carousel',
      contents: filtered_subscriptions.map do |subscription|
        create_bubble(subscription)
      end
    }
  }
end


def create_bubble(subscription)
    hero_section = if subscription.img == 'no_img.png'
                   {
                     type: 'image',
                     url: 'https://i.imgur.com/5cpEjhj.png', # 外部からアクセス可能な画像のURL
                     size: 'full',
                     aspectMode: 'cover',
                     aspectRatio: '2:1'
                   }
                 else
                   {
                     type: 'image',
                     url: subscription.img, # 外部からアクセス可能な画像のURL
                     size: 'full',
                     aspectMode: 'cover',
                     aspectRatio: '2:1'
                   }
                 end
  bubble_contents = {
    type: 'bubble',
    styles: {
      body: {
        backgroundColor: '#F1F4C2',
      },
      footer: {
        backgroundColor: '#F1F4C2',
      }
    },
    hero: hero_section,
    body: {
      type: 'box',
      layout: 'vertical',
      contents: [
        {
          type: 'text',
          text: subscription.title,
          weight: 'bold',
          size: 'lg',
          wrap: true
        },
        {
          type: 'box',
          layout: 'baseline',
          contents: [
            {
              type: 'text',
              text: '上映映画館:',
              color: '#656565',
              size: 'sm',
              flex: 2
            },
            {
              type: 'text',
              text: Theater.find_by(name: subscription.theater).official,
              wrap: true,
              color: '#656565',
              size: 'sm',
              flex: 5
            }
          ]
        },
        {
          type: 'box',
          layout: 'baseline',
          contents: [
            {
              type: 'text',
              text: '終了予定日:',
              color: '#656565',
              size: 'sm',
              flex: 2
            },
            {
              type: 'text',
              text: subscription.finish ? subscription.finish : '終了日未定',
              color: subscription.finish ? '#FF0000' : '#656565', 
              wrap: true,
              size: 'sm',
              flex: 5
            }
          ]
        }
      ]
    },
    footer: {
      type: 'box',
      layout: 'vertical',
      spacing: 'sm',
      contents: [
        {
          type: 'button',
          style: 'secondary',
          color: '#F1F4C2', 
          action: {
            type: 'postback',
            label: '削除する',
            data: "action=delete&movie_id=#{subscription.id}",
            displayText: ">#{subscription.title}を削除"
          }
        }
      ]
    }
  }
  
  bubble_contents.delete(:hero) if hero_section.nil? # ヒーローセクションがnilの場合、削除します
  bubble_contents
end

def create_confirmation_message(movie_id)
  {
    type: 'flex',
    altText: 'この映画を削除しますか？',
    contents: {
      type: 'bubble',
      styles: {
        body: {
          backgroundColor: '#F1F4C2'
        }
      },
      body: {
        type: 'box',
        layout: 'vertical',
        contents: [
          {
            type: 'text',
            text: 'この映画を削除しますか？',
            wrap: true,
          },
          {
            type: 'box',
            layout: 'horizontal',
            margin: 'lg',
            contents: [
              {
                type: 'button',
                action: {
                  type: 'postback',
                  label: 'はい',
                  data: "action=confirm_delete&movie_id=#{movie_id}"
                },
                style: 'secondary',
                color: '#F1F4C2', 
              },
              {
                type: 'button',
                action: {
                  type: 'postback',
                  label: 'いいえ',
                  data: "action=cancel_delete"
                },
                style: 'secondary',
                color: '#F1F4C2', 
              }
            ]
          }
        ]
      }
    }
  }
end
