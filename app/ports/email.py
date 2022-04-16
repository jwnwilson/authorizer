from abc import ABC

from pydantic import BaseModel


class EmailData(BaseModel):
    user_id: str
    subject: str
    recipients: list[str]
    text: str
    html: str
    attachments: list[str]


class EmailTemplateData(BaseModel):
    user_id: str
    subject: str
    recipients: list[str]
    template_id: str
    template_params: dict
    attachments: list[str]


class EmailAdapter(ABC):
    def send(self, email_data: EmailData):
        raise NotImplementedError

    def send_template(self, email_data: EmailTemplateData):
        raise NotImplementedError
