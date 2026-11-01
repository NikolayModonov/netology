#!/usr/bin/python
# -*- coding: utf-8 -*-

from ansible.module_utils.basic import AnsibleModule
import os

def main():
    module = AnsibleModule(
        argument_spec=dict(
            path=dict(type='str', required=True),
            content=dict(type='str', required=True)
        ),
        supports_check_mode=True
    )

    path = module.params['path']
    content = module.params['content']

    result = dict(
        changed=False,
        message=''
    )

    if module.check_mode:
        module.exit_json(**result)

    try:
        if os.path.exists(path):
            with open(path, 'r') as f:
                existing_content = f.read()
            if existing_content == content:
                result['message'] = 'File already exists with the same content'
                module.exit_json(**result)
        
        dir_name = os.path.dirname(path)
        if dir_name:
            os.makedirs(dir_name, exist_ok=True)
            
        with open(path, 'w') as f:
            f.write(content)
        
        result['changed'] = True
        result['message'] = 'File created/updated successfully'
        module.exit_json(**result)

    except Exception as e:
        module.fail_json(msg=str(e), **result)

if __name__ == '__main__':
    main()