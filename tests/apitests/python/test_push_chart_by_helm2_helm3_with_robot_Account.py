from __future__ import absolute_import


import unittest

from testutils import ADMIN_CLIENT, CHART_API_CLIENT, suppress_urllib3_warning
from testutils import harbor_server
from testutils import TEARDOWN
import library.repository
import library.helm
from library.robot import Robot
from library.project import Project
from library.user import User
from library.chart import Chart

class TestProjects(unittest.TestCase):
    @suppress_urllib3_warning
    def setUp(self):
        self.project= Project()
        self.user= User()
        self.chart=  Chart()
        self.robot = Robot()
        self.url = ADMIN_CLIENT["endpoint"]
        self.chart_api_url = CHART_API_CLIENT['endpoint']
        self.user_push_chart_password = "Aa123456"
        self.chart_file = "https://storage.googleapis.com/harbor-builds/helm-chart-test-files/harbor-0.2.0.tgz"
        self.archive = "harbor/"
        self.CHART_NAME=self.archive.replace("/", "")
        self.verion = "0.2.0"
        self.chart_repo_name = "chart_local"
        self.repo_name = "harbor_api_test"

    @unittest.skipIf(TEARDOWN == False, "Test data won't be erased.")
    def tearDown(self):
        #1. Delete user(UA).
        self.user.delete_user(TestProjects.user_id, **ADMIN_CLIENT)

    def testPushChartToChartRepoByHelm2WithRobotAccount(self):
        """
        Test case:
            Push Chart File To Chart Repository By Helm V2 With Robot Account
        Test step and expected result:
            1. Create a new user(UA);
            2. Create private project(PA) with user(UA);
            3. Create a new robot account(RA) with full priviliges in project(PA) with user(UA);
            4. Push chart to project(PA) by Helm2 CLI with robot account(RA);
            5. Get chart repositry from project(PA) successfully;
        Tear down:
            1. Delete user(UA).
        """

        #1. Create user(UA);
        TestProjects.user_id, user_name = self.user.create_user(user_password = self.user_push_chart_password, **ADMIN_CLIENT)
        TestProjects.USER_CLIENT=dict(endpoint = self.url, username = user_name, password = self.user_push_chart_password)
        TestProjects.API_CHART_CLIENT=dict(endpoint = self.chart_api_url, username = user_name, password = self.user_push_chart_password)
        #2. Create private project(PA) with user(UA);
        TestProjects.project_id, TestProjects.project_name = self.project.create_project(metadata = {"public": "false"}, **TestProjects.USER_CLIENT)


        #3. Create a new robot account(RA) with full priviliges in project(PA) with user(UA);
        robot_id, robot_account = self.robot.create_project_robot(TestProjects.project_name,
                                                                         30 ,**TestProjects.USER_CLIENT)
        #4. Push chart to project(PA) by Helm2 CLI with robot account(RA);"
        library.helm.helm2_add_repo(self.chart_repo_name, "https://"+harbor_server, TestProjects.project_name, robot_account.name, robot_account.secret)
        library.helm.helm2_push(self.chart_repo_name, self.chart_file, TestProjects.project_name, robot_account.name, robot_account.secret)

        #5. Get chart repositry from project(PA) successfully;
        self.chart.chart_should_exist(TestProjects.project_name, self.CHART_NAME, **TestProjects.API_CHART_CLIENT)

        #6. Push chart to project(PA) by Helm3 CLI with robot account(RA);
        chart_cli_ret = library.helm.helm_chart_push_to_harbor(self.chart_file, self.archive,  harbor_server, TestProjects.project_name, self.repo_name, self.verion, robot_account.name, robot_account.secret)


if __name__ == '__main__':
    unittest.main()

