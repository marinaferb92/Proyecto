from django.urls import path
from . import views_public

urlpatterns = [
    path("", views_public.home, name="public_home"),
    path("servicios/", views_public.servicios, name="public_servicios"),
    path("pedir-cita/", views_public.pedir_cita, name="public_pedir_cita"),
    path("gracias/", views_public.gracias, name="public_gracias"),
]
