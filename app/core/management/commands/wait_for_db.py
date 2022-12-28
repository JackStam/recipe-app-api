"""
Django command to wait for the database to be available
"""

from django.core.management import BaseCommand


class Commnad(BaseCommand):
    """"Django command to wait for database"""

    def handle(self, *args, **options):
        pass
