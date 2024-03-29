"""
Django settings for django_forum project.

Generated by 'django-admin startproject' using Django 3.1.5.

For more information on this file, see
https://docs.djangoproject.com/en/3.1/topics/settings/

For the full list of settings and their values, see
https://docs.djangoproject.com/en/3.1/ref/settings/
"""
DEBUG = True
MYPY = False
## TODO: clearsessions cron job

import sys, os
from pathlib import Path

from dotenv import load_dotenv

from django.urls import reverse_lazy
from django.utils import timezone

load_dotenv()

# Build paths inside the project like this: BASE_DIR / 'subdir'.
BASE_DIR = str(os.getenv("BASE_DIR"))

# Quick-start development settings - unsuitable for production
# See https://docs.djangoproject.com/en/3.1/howto/deployment/checklist/
# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = str(os.getenv("SECRET_KEY"))

ALLOWED_HOSTS = [
    os.getenv("ALLOWED_HOSTS1"),
    os.getenv("ALLOWED_HOSTS2"),
    os.getenv("ALLOWED_HOSTS3"),
]

# Application definition

INSTALLED_APPS = [
    "django_password_validators",
    "django_password_validators.password_history",
    "django_users",
    "django_profile",
    "django_messages",
    "django_forum",
    "django_bs_carousel",
    "django_artisan",
    "django_email_verification",
    "django.contrib.admin",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",
    "django.contrib.sites",
    "django.contrib.sitemaps",
    "crispy_forms",
    "crispy_bootstrap5",
    "captcha",  # django-recaptcha
    "tinymce",
    "sorl.thumbnail",
    "django_elasticsearch_dsl",
    "django_q",
    "dbbackup",
    "debug_toolbar",
    "pipeline",
]

MIDDLEWARE = [
    "django.middleware.security.SecurityMiddleware",
    "django.middleware.cache.UpdateCacheMiddleware",
    "django.middleware.gzip.GZipMiddleware",
    "debug_toolbar.middleware.DebugToolbarMiddleware",
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.middleware.common.CommonMiddleware",
    "django.middleware.cache.FetchFromCacheMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
    "django_users.middleware.ReauthenticateMiddleware",
]

SESSION_ENGINE = "django.contrib.sessions.backends.cached_db"
SESSION_CACHE_ALIAS = "default"

ROOT_URLCONF = "{}.urls".format(os.getenv("DJANGO_PROJECT_NAME"))

TEMPLATE_DIR = "templates/"
TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "DIRS": [],
        "APP_DIRS": True,
        "OPTIONS": {
            "context_processors": [
                "django.template.context_processors.debug",
                "django.template.context_processors.request",
                "django.contrib.auth.context_processors.auth",
                "django.contrib.messages.context_processors.messages",
                "django_forum.context_processors.siteName",
                "django_artisan.context_processors.navbarSpiel",
                "django_artisan.context_processors.siteLogo",
                "django_artisan.context_processors.base_html",
                "django_artisan.context_processors.category_visible",
                "django_artisan.context_processors.location_visible",
                "django_artisan.context_processors.max_images",
            ],
        },
    },
]

# base_html for context_processors
BASE_HTML = "django_artisan/base.html"


# to get debug toolbar to show up
def show_toolbar(request):
    return True


DEBUG_TOOLBAR_CONFIG = {
    "SHOW_TOOLBAR_CALLBACK": show_toolbar,
}

# django-q
Q_CLUSTER = {
    "name": "DJRedis",
    "workers": 4,
    "timeout": 20,
    "retry": 60,
    "django_redis": "default",
}

# dbbackup
DBBACKUP_STORAGE = "storages.backends.dropbox.DropBoxStorage"
DBBACKUP_STORAGE_OPTIONS = {
    "oauth2_access_token": os.getenv("DROPBOX_OAUTH_TOKEN"),
}
DBBACKUP_CLEANUP_KEEP = 10
DBBACKUP_CLEANUP_KEEP_MEDIA = 5


# Database
# https://docs.djangoproject.com/en/3.1/ref/settings/#databases

DATABASES = {
    "default": {
        "ENGINE": os.getenv("DB_ENGINE"),
        "NAME": os.getenv("DB_NAME"),
        "USER": os.getenv("DB_USER"),
        "PASSWORD": os.getenv("DB_PASSWORD"),
        "HOST": os.getenv("DB_HOST"),
        "PORT": os.getenv("DB_PORT"),
    }
}

CACHES = {
    "default": {
        "BACKEND": "django_redis.cache.RedisCache",
        "LOCATION": "redis://127.0.0.1:6379",
        "OPTIONS": {
            "CLIENT_CLASS": "django_redis.client.DefaultClient",
            "COMPRESSOR": "django_redis.compressors.zlib.ZlibCompressor",
        },
    }
}

# Password validation
# https://docs.djangoproject.com/en/3.1/ref/settings/#auth-password-validators

AUTH_PASSWORD_VALIDATORS = [
    # {
    #     'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    # },
    # {
    #     'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    #     'OPTIONS': {
    #         'min_length': 12,
    #      }
    # },
    # {
    #     'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    # },
    # {
    #     'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    # },
    # {
    #     'NAME': 'django_password_validators.password_history.password_validation.UniquePasswordsValidator',
    #     'OPTIONS': {
    #              # How many recently entered passwords matter.
    #              # Passwords out of range are deleted.
    #              # Default: 0 - All passwords entered by the user. All password hashes are stored.
    #         'last_passwords': 5 # Only the last 5 passwords entered by the user
    #     }
    # },
    # {
    #     'NAME': 'django_password_validators.password_character_requirements.password_validation.PasswordCharacterValidator',
    #     'OPTIONS': {
    #         'min_length_digit': 1,
    #         'min_length_alpha': 1,
    #         'min_length_special': 0,
    #         'min_length_lower': 1,
    #         'min_length_upper': 1,
    #         'special_characters': ""
    #     }
    # },
]

# TODO: consider using shadowd web app firewall, if there is enough power...

# Internationalization
# https://docs.djangoproject.com/en/3.1/topics/i18n/

LANGUAGE_CODE = "en-gb"

TIME_ZONE = "Europe/Jersey"
USE_I18N = True

USE_L10N = True

USE_TZ = True

# primary key
DEFAULT_AUTO_FIELD = "django.db.models.AutoField"

# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/3.1/howto/static-files/
STATIC_URL = "static/"
STATIC_ROOT = os.path.join(str(os.getenv("STATIC_BASE_ROOT")), STATIC_URL)

MEDIA_URL = "media/"
MEDIA_ROOT = os.path.join(str(os.getenv("STATIC_BASE_ROOT")), MEDIA_URL)

# django artisan
CONTENT_TYPES = ["image"]

#  gallery
# django_forum
IMAGE_UPLOAD_PATH = "/uploads/users/"

MAX_USER_IMAGES = 3
ALLOWED_EXTENSIONS = ["jpg", "png", "webp"]
MAX_UPLOAD_SIZE = "2.5Mb"
FILE_UPLOAD_DIRECTORY_PERMISSIONS = 0o700
FILE_UPLOAD_PERMISSIONS = 0o644

# make packages abstract
ABSTRACTPROFILE = True
ABSTRACTFORUMPROFILE = True
ABSTRACTMESSAGE = True
ABSTRACTPOST = True
POST_MODEL = "django_artisan.Post"

# django-pipeline
STATICFILES_STORAGE = "pipeline.storage.PipelineManifestStorage"
STATICFILES_FINDERS = (
    "django.contrib.staticfiles.finders.FileSystemFinder",
    "django.contrib.staticfiles.finders.AppDirectoriesFinder",
    "pipeline.finders.PipelineFinder",
)

PIPELINE = {
    "PIPELINE_ENABLED": True,
    "JS_COMPRESSOR": "pipeline.compressors.jsmin.JSMinCompressor",
    "CSS_COMPRESSOR": "pipeline.compressors.csshtmljsminify.CssHtmlJsMinifyCompressor",
    "STYLESHEETS": {
        "main_styles": {
            "source_filenames": ("django_artisan/css/styles.css",),
            "output_filename": "css/styles_min.css",
        },
        "registration_styles": {
            "source_filenames": ("django_users/css/balloons.css",),
            "output_filename": "css/blns_min.css",
        },
        "carousel_styles": {
            "source_filenames": ("django_bs_carousel/css/styles.css",),
            "output_filename": "css/crsl_min.css",
        },
    },
    "JAVASCRIPT": {
        "django_bs_carousel": {
            "source_filenames": ("django_bs_carousel/js/carousel.js",),
            "output_filename": "django_bs_carousel/js/c_min.js",
        },
        "django_bs_image_loader": {
            "source_filenames": ("django_bs_carousel/js/imageLoader.js",),
            "output_filename": "django_bs_carousel/js/il_min.js",
        },
        "django_forum": {
            "source_filenames": ("django_forum/js/*.js",),
            "output_filename": "js/df_min.js",
        },
        "django_artisan": {
            "source_filenames": ("django_artisan/js/profileUpdate.js",),
            "output_filename": "js/da_min.js",
        },
    },
}


# django_users
LOGIN_REDIRECT_URL = reverse_lazy("django_artisan:post_list_view")
LOGOUT_REDIRECT_URL = reverse_lazy("django_artisan:landing_page")
LOGIN_URL = reverse_lazy("login")

# sorl-thumbnail
THUMBNAIL_SIZE = (120, 120)
# THUMBNAIL_DEBUG = True
# THUMBNAIL_ENGINE = 'sorl.thumbnail.engines.wand_engine.Engine'

# django_bs_carousel_lazy_load
# the first two settings are used when uploading and imageby the management command makeusers
# and are also used by the carousel.  In the management command, or when
# images are uploaded, sorl-thumbnail creates two memoized images for later use
# by the carousel, when the two values below are used as sizes for carousel.html
IMAGE_SIZE_LARGE = "1024x768"
IMAGE_SIZE_SMALL = "360x640"

NUM_IMAGES_PER_REQUEST = 5

CAROUSEL_RANDOMIZE_IMAGES = True
CAROUSEL_USE_CACHE = False
CAROUSEL_OFFSET = True
CAROUSEL_IMG_PAUSE = 6500
DJANGO_BS_CAROUSEL_IMAGE_MODEL = "django_artisan.UserProductImage"

# django_forum
IMAGE_UPLOAD_PATH = "/uploads/users/"

# DJANGO-EMAIL-VERIFICATION SETTINGS
def verified_callback(user):
    user.is_active = True


EMAIL_BACKEND = "django.core.mail.backends.console.EmailBackend"
EMAIL_VERIFIED_CALLBACK = verified_callback
EMAIL_ACTIVE_FIELD = "is_active"
# EMAIL_HOST = 'smtp.gmail.com'
# EMAIL_PORT = 587
EMAIL_HOST_USER = "development@django_artisan.com"
# os.getenv("EMAIL_APP_ADDRESS")
EMAIL_FROM_ADDRESS = "noreply@django_artisan.com"
# os.getenv("EMAIL_FROM_ADDRESS")
EMAIL_HOST_PASSWORD = os.getenv("EMAIL_APP_KEY")
EMAIL_MAIL_SUBJECT = "Confirm your email"
EMAIL_MAIL_HTML = "emails/mail_body.html"
EMAIL_MAIL_PLAIN = "emails/mail_body.txt"
EMAIL_PAGE_TEMPLATE = "registration/confirm.html"
EMAIL_PAGE_DOMAIN = "http://127.0.0.1:8000"
EMAIL_TOKEN_LIFE = 60 * 60 * 24
# EMAIL_USE_TLS = True
CUSTOM_SALT = os.getenv("CUSTOM_SALT")

## RECAPTCHA SETTINGS
RECAPTCHA_PUBLIC_KEY = "6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI"
RECAPTCHA_PRIVATE_KEY = "6LeIxAcTAAAAAGG-vFI1TnRWxMZNFuojJ4WifJWe"

SILENCED_SYSTEM_CHECKS = ["captcha.recaptcha_test_key_error"]

## SESSION SETTINGS
SESSION_EXPIRE_AT_BROWSER_CLOSE = True
SESSION_COOKIE_AGE = 129600  # 36 hours.  # defaults to two weeks
SESSION_COOKIE_SECURE = True  # set this to true when using https
# SESSION_SAVE_EVERY_REQUEST = True  #updates timestamp to increase session_cookie_age

# the amount of time before a comment or post is hard deleted
DELETION_TIMEOUT = {
    "POST": timezone.timedelta(days=21),
    "COMMENT": timezone.timedelta(days=14),
}

# the amount of time to wait before emails are sent to subscribed users.  This is in case someone
# deletes their comment immediately.
COMMENT_WAIT = timezone.timedelta(seconds=600)
# msg sent to subscribed users
# the msg must include one pair of brackets, which will contain
# the href of the post
SUBSCRIBED_MSG = "<h3 style='color: blue;'>Ceramic Isles</h3><br>A new comment has been added to a post that you are subscribed to!<br>Follow this link to view the post and comments: {}"

# settings for bleach

ALLOWED_TAGS = [
    "a",
    "div",
    "p",
    "span",
    "img",
    "iframe",
    "em",
    "i",
    "li",
    "ol",
    "ul",
    "strong",
    "br",
    "h1",
    "h2",
    "h3",
    "h4",
    "h5",
    "h6",
    "table",
    "tbody",
    "thead",
    "tr",
    "td",
    "abbr",
    "acronym",
    "b",
    "blockquote",
    "code",
    "strike",
    "u",
    "sup",
    "sub",
]

STYLES = ["background-color", "font-size", "line-height", "color", "font-family"]

ATTRIBUTES = {
    "*": [
        "style",
        "align",
        "title",
    ],
    "a": [
        "href",
    ],
    "iframe": ["src", "height", "width", "allowfullscreen"],
}

TINYMCE_DEFAULT_CONFIG = {
    "menubar": False,
    "min-height": "500px",
    "browser_spellcheck": True,
    "contextmenu": False,
    "plugins": "advlist autolink lists link image charmap print preview anchor searchreplace fullscreen insertdatetime media table paste code help wordcount spellchecker",
    "toolbar": "undo redo | bold italic underline strikethrough | fontselect fontsizeselect formatselect | alignleft aligncenter alignright alignjustify | outdent indent |  numlist bullist checklist | forecolor backcolor casechange permanentpen formatpainter removeformat | pagebreak | charmap emoticons | fullscreen  preview save print | insertfile image media template link anchor | a11ycheck ltr rtl | showcomments addcomment table",
    "custom_undo_redo_levels": 10,
    "selector": "textarea",
}

# django crispy forms
CRISPY_ALLOWED_TEMPLATE_PACKS = "bootstrap5"
CRISPY_TEMPLATE_PACK = "bootstrap5"

CLAMAV_SOCKET = str(os.getenv("CLAMAV_ADDRESS"))


# elastic search

ELASTICSEARCH_DSL = {
    "default": {"hosts": str(os.getenv("ELASTIC_SEARCH_ADDRESS"))},
}

### ABOUT PAGE
ABOUT_US_SPIEL = "<span class='spiel-headline'>Ceramic Isles</span> <span class='spiel-normal'>as a website is presented \
                  on behalf of ceramicists, sculptors, potters \
                  and anyone else who likes to work with clay, \
                  in the Channel Islands.</span>"

### NAVBAR
NAVBAR_SPIEL = "Welcome to Ceramic Isles, a site where ceramic artists \
                local to the Channel Islands are able to meet, chat, and show off their work. \
                If you are a ceramic artist local to one of the Channel Islands, consider \
                registering as a user to be able to access the forum, \
                and to be able present images of your work here, on this page.<br> \
                Click the Ceramic Isles Logo to return to the landing page \
                which acts as a gallery for member's work.<br> \
                On a diet???  This site is cookie free!<br> \
                Problems??? contact - ceramic_isles [at] gmail.com"

### The following are used by django_artisan and django_forum
SITE_NAME = str(os.getenv("SITE_NAME"))
SITE_LOGO = "django_artisan/images/vase.svg"
SITE_DOMAIN = "127.0.0.1:8000"
# for the sites framework so that sitemaps will work
SITE_ID = 1

# category and location
SHOW_CATEGORY = True
SHOW_LOCATION = True

from django.db import models
from django.utils.translation import gettext_lazy as _


class CATEGORY(models.TextChoices):
    EVENT = "EV", _("Event")
    QUESTION = "QN", _("Question")
    GENERAL = "GL", _("General")
    PICTURES = "PS", _("Pictures")
    FORSALE = "FS", _("For Sale")


class LOCATION(models.TextChoices):
    ANY_ISLE = "AI", _("Any")
    ALDERNEY = "AY", _("Alderney")
    GUERNSEY = "GY", _("Guernsey")
    JERSEY = "JE", _("Jersey")
    SARK = "SK", _("Sark")


# logging
def skip_mtime_seen(record):
    if "mtime" in record.getMessage():  # filter whatever you want
        return False
    return True


def skip_djangoq_schedule(record):
    if "schedule" in record.getMessage():
        return False
    return True


LOGGING = {
    "version": 1,
    "disable_existing_loggers": False,
    "filters": {
        # use Django's built in CallbackFilter to point to your filter
        "skip_mtime_seen": {
            "()": "django.utils.log.CallbackFilter",
            "callback": skip_mtime_seen,
        },
        "skip_djangoq_schedule": {
            "()": "django.utils.log.CallbackFilter",
            "callback": skip_djangoq_schedule,
        },
    },
    "formatters": {
        "django": {
            "()": "django.utils.log.ServerFormatter",
            "format": "[{server_time}] - {pathname} - {message}",
            "style": "{",
        },
        "verbose": {
            "format": "{levelname} {asctime} {pathname} {module} {process:d} {thread:d} {message}",
            "style": "{",
        },
    },
    "handlers": {
        "file": {
            "level": "DEBUG",
            "class": "logging.FileHandler",
            "filename": "/var/log/{}/django/debug.log".format(
                str(os.getenv("PROJECT_NAME"))
            ),
            "formatter": "verbose",
            "filters": ["skip_mtime_seen", "skip_djangoq_schedule"],
        },
        "console": {
            "level": "ERROR",
            "class": "logging.StreamHandler",
            "formatter": "django",
        },
    },
    "loggers": {
        "django": {
            "handlers": ["file"],
            "propagate": True,
            "level": "DEBUG",
        },
        "django_artisan": {
            "handlers": ["file", "console"],
            "level": "DEBUG",
            "propagate": True,
        },
        "safe_imagefield": {
            "handlers": ["file", "console"],
            "level": "DEBUG",
            "propagate": True,
        },
    },
}

# I think sentry in dev mode is not secure...
# import sentry_sdk
# from sentry_sdk.integrations.django import DjangoIntegration
# from sentry_sdk.integrations.redis import RedisIntegration

# sentry_sdk.init(
#     dsn="https://0f35df857c1f4ea19b61fa76729dde9e@o803843.ingest.sentry.io/5802934",
#     integrations=[DjangoIntegration(), RedisIntegration()],

#     # Set traces_sample_rate to 1.0 to capture 100%
#     # of transactions for performance monitoring.
#     # We recommend adjusting this value in production.
#     traces_sample_rate=1.0,

#     # If you wish to associate users to errors (assuming you are using
#     # django.contrib.auth) you may enable sending PII data.
#     send_default_pii=True
# )
