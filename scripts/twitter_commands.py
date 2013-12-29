from twython import Twython, TwythonError
import sys

class TwitterCommands:
    """
    Commands that will be executed when a user executes a voice command on the Cocoa application  
    """
    def __init__(self):
        #app key, secret, oauth token, oauth secret. modify
        APP_KEY = ''
        APP_SECRET = ''
        OAUTH_TOKEN = ''
        OAUTH_SECRET = ''
        self.twitter = Twython(APP_KEY, APP_SECRET, OAUTH_TOKEN, OAUTH_SECRET)
        self.twitter.verify_credentials()

    def send_tweet(self, tweet):
        self.twitter.update_status(status=tweet)

    def update_avatar(self, file_path):
        avatar = open(file_path, 'rb')
        self.twitter.update_profile_image(image=avatar)

    def search_twitter(self, keywords):
        search_dict = self.twitter.search(q=keywords, result_type='popular')
        for elem in search_dict['statuses']:
            print elem['text']

    def tweet_image(self, file_path, message):
        photo = open(file_path, 'rb')
        self.twitter.update_status_with_media(status=message, media=photo)

    
def main():
    twitter_commands = TwitterCommands()
    if sys.argv[1] == "--help":
        print "update_avatar file_path"
        print "tweet_image"
        print "send_tweet message"
        print "search_twitter keyword"
    elif sys.argv[1] == "update_avatar":
        twitter_commands.update_avatar(sys.argv[2])
    elif sys.argv[1] == "tweet_image":
        twitter_commands.tweet_image(sys.argv[2], sys.argv[3]) 
    elif sys.argv[1] == "send_tweet":
        twitter_commands.send_tweet(sys.argv[2])
    elif sys.argv[1] == "search_twitter":
        twitter_commands.search_twitter(sys.argv[2])
    
if __name__ == "__main__":
    main()
