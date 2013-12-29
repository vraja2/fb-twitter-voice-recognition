import facebook
import urllib
import urllib2
import json
import sys

class FacebookCommands:
    def __init__(self):
        #fb access token. modify
        self.token = ''
        self.graph = facebook.GraphAPI(self.token)
        self.profile = self.graph.get_object("me")
        self.friends = self.graph.get_connections("me", "friends")
        self.redirect_client_url = 'http://vigneshraja.com'
        #fb secret and key. modify
        self.consumer_secret = ''
        self.consumer_key = ''
        self.uid = ''
  
    def create_test_user(self):
        """
        Creates a developer test user with Facebook 
        """
        response = urllib2.urlopen('https://graph.facebook.com/%s/accounts/test-users?installed=true&name=test_acc&locale=en_US&permissions=publish_stream&method=post&access_token=%s' % (self.consumer_key, self.token))

    def get_test_user(self):
        response = urllib2.urlopen('https://graph.facebook.com/%s/accounts/test-users?access_token=%s' % (self.consumer_key,self.token))
        print response.read()

    def update_status(self, status):
        self.graph.put_object("me", "feed", message=status)

    def upload_photo(self, message, file_path):
        photo = open(file_path, 'rb')
        self.graph.put_photo(photo, message)
        photo.close()

    def get_friends(self):
        """
        Return a list of your Facebook friends
        """
        friends = self.graph.get_connections("me", "friends")
        return friends['data']

    def get_most_recent_notification(self):
        response = urllib2.urlopen('https://graph.facebook.com/' + self.uid + '/notifications?access_token=%s' % self.token) 
        resp = response.read()
        json_resp = json.loads(resp)
        return json_resp['data'][0]['title']

    def get_recent_friend_requests(self):
        """
        Returns the number of friends requests you have
        """
        response = urllib2.urlopen('https://graph.facebook.com/' + self.uid + '/friendrequests?access_token=%s' % self.token)
        resp = response.read()
        json_resp = json.loads(resp)
        return str(len(json_resp['data']))

    def post_to_friends_wall(self, post):
        post_data = {'access_token': self.token, 'message':'gustav'}
        request_path = str(803945290) + '/feed'
        post_data = urllib.urlencode(post_data)
        response = urllib2.urlopen('https://graph.facebook.com/%s' % request_path, post_data)

    def add_school(self, school_name):
        #add stuff
        post_data = {'gender':'female'}
        post_data = urllib.urlencode(post_data)
        response = urllib2.urlopen('https://graph.facebook.com/'+ self.uid + '/me?access_token=%s&gender=male' % self.token)

    def add_work(self, employer_name):
        #add stuff
        print "not implemented"

def main():
    fb_commands = FacebookCommands()
    #fb_commands.get_test_user()
    #fb_commands.create_test_user()
    if sys.argv[1] == "--help":
        print "get_friend_requests"
        print "get_recent_notification"
        print "get_friends"
        print "update_status status"
        print "upload_photo message"
    elif sys.argv[1] == "get_friend_requests":
        print "You have " + fb_commands.get_recent_friend_requests() + " friend request(s)"
    elif sys.argv[1] == "get_recent_notification":
        print fb_commands.get_most_recent_notification()
    elif sys.argv[1] == "get_friends":
        print fb_commands.get_friends()
    elif sys.argv[1] == "update_status":
        fb_commands.update_status(sys.argv[2])
    elif sys.argv[1] == "upload_photo":
        fb_commands.upload_photo(sys.argv[2], sys.argv[3])
    

if __name__ == "__main__":
    main()
