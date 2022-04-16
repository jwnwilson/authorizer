import logging

import requests

from app.ports.email import EmailAdapter, EmailData, EmailTemplateData

logger = logging.getLogger(__name__)


class EmailException(Exception):
    pass


class EmailService(EmailAdapter):
    def __init__(self, service_url, access_token):
        self.service_url = service_url
        self.access_token = access_token

    def _validate_response(self, response):
        if response.status == 200:
            return

        error_msg = f"Error sending email to user: {response.content}"
        logger.error(error_msg)
        raise EmailException(error_msg)

    def _send_email_request(self, url, data: dict):
        return requests.post(
            url, data=data, headers={"Authorization": f"Bearer {self.access_token}"}
        )

    def send(self, email_data: EmailData):
        logger.info(f"Sending Email to user: {email_data.user_id}")
        resp = self._send_email_request(
            self.service_url + "/email/send", email_data.dict()
        )
        self._validate_response(resp)
        logger.info(f"Sent Email to user: {email_data.user_id}")

    def send_template(self, email_data: EmailTemplateData):
        logger.info(f"Sending Template Email to user: {email_data.user_id}")
        resp = self._send_email_request(
            self.service_url + "/email/send-template", email_data.dict()
        )
        self._validate_response(resp)
        logger.info(f"Sent Template Email to user: {email_data.user_id}")
