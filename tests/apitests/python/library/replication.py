# -*- coding: utf-8 -*-

import time
import base
import v2_swagger_client

class Replication(base.Base, object):
    def __init__(self):
        super(Replication,self).__init__(api_type = "replication")

    def wait_until_jobs_finish(self, rule_id, retry=10, interval=5, **kwargs):
        Succeed = False
        for i in range(retry):
            Succeed = False
            jobs = self.get_replication_executions(rule_id, **kwargs)
            for job in jobs:
                if job.status == "Succeed":
                    return
            if not Succeed:
                time.sleep(interval)
        if not Succeed:
            raise Exception("The jobs not Succeed")

    def trigger_replication_executions(self, rule_id, expect_status_code = 201, **kwargs):
        _, status_code, _ = self._get_client(**kwargs).start_replication_with_http_info({"policy_id":rule_id})
        base._assert_status_code(expect_status_code, status_code)

    def get_replication_executions(self, rule_id, expect_status_code = 200, **kwargs):
        data, status_code, _ = self._get_client(**kwargs).list_replication_executions_with_http_info(policy_id=rule_id)
        base._assert_status_code(expect_status_code, status_code)
        return data

    def create_replication_policy(self, dest_registry=None, src_registry=None, name=None, description="",
                                  dest_namespace = "", filters=None, trigger=v2_swagger_client.ReplicationTrigger(type="manual",trigger_settings=v2_swagger_client.ReplicationTriggerSettings(cron="")),
                                  deletion=False, override=True, enabled=True, expect_status_code = 201, **kwargs):
        if name is None:
            name = base._random_name("rule")
        if filters is None:
            filters = []

        policy = v2_swagger_client.ReplicationPolicy(name=name, description=description,dest_namespace=dest_namespace,
                                                  dest_registry=dest_registry, src_registry=src_registry,filters=filters,
                                                  trigger=trigger, deletion=deletion, override=override, enabled=enabled)
        _, status_code, header = self._get_client(**kwargs).create_replication_policy_with_http_info(policy)
        base._assert_status_code(expect_status_code, status_code)
        return base._get_id_from_header(header), name

    def get_replication_rule(self, param = None, rule_id = None, expect_status_code = 200, **kwargs):
        if rule_id is None:
            if param is None:
                param = dict()
            data, status_code, _ = self._get_client(**kwargs).get_replication_policy_with_http_info(param)
        else:
            data, status_code, _ = self._get_client(**kwargs).get_replication_policy_with_http_info(rule_id)
        base._assert_status_code(expect_status_code, status_code)
        return data

    def check_replication_rule_should_exist(self, check_rule_id, expect_rule_name, expect_trigger = None, **kwargs):
        rule_data = self.get_replication_rule(rule_id = check_rule_id, **kwargs)
        if str(rule_data.name) != str(expect_rule_name):
            raise Exception(r"Check replication rule failed, expect <{}> actual <{}>.".format(expect_rule_name, str(rule_data.name)))
        else:
            print(r"Check Replication rule passed, rule name <{}>.".format(str(rule_data.name)))
            #get_trigger = str(rule_data.trigger.kind)
            #if expect_trigger is not None and get_trigger == str(expect_trigger):
            #    print r"Check Replication rule trigger passed, trigger name <{}>.".format(get_trigger)
            #else:
            #    raise Exception(r"Check replication rule trigger failed, expect <{}> actual <{}>.".format(expect_trigger, get_trigger))

    def delete_replication_rule(self, rule_id, expect_status_code = 200, **kwargs):
        _, status_code, _ = self._get_client(**kwargs).delete_replication_policy_with_http_info(rule_id)
        base._assert_status_code(expect_status_code, status_code)

