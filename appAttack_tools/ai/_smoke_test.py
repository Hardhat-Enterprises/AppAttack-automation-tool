from appAttack_tools.ai.config_manager import store_api_key, get_api_key, MASTER_KEY_PATH, KEYS_ENC_PATH
import os
print('master before', os.path.exists(MASTER_KEY_PATH))
try:
    store_api_key('test_provider','sekret123')
    print('store_api_key succeeded')
    print('master after', os.path.exists(MASTER_KEY_PATH))
    print('keys_enc exists', os.path.exists(KEYS_ENC_PATH))
    print('get key', get_api_key('test_provider'))
except Exception as e:
    print('store/get failed:', e)
