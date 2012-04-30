# Load and apply pusher app configuration from yaml file
pusher_config = YAML.load_file(Rails.root.join('config', 'pusher.yml'))

Pusher.app_id = pusher_config['app_id']
Pusher.key = pusher_config['key']
Pusher.secret = pusher_config['secret']