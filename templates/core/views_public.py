from django.shortcuts import render, redirect
from django.utils.timezone import now
from .models import Clientes, Citas, Tratamientos

def home(request):
    return render(request, "public/home.html", {"year": now().year})

def servicios(request):
    return render(request, "public/servicios.html", {"year": now().year})

def pedir_cita(request):
    tratamientos = Tratamientos.objects.all()

    if request.method == "POST":
        nombre = request.POST['nombre']
        telefono = request.POST['telefono']
        tratamiento_id = request.POST['tratamiento_id']
        fecha = request.POST['fecha']
        hora = request.POST['hora']

        cliente, _ = Clientes.objects.get_or_create(
            nombre=nombre,
            telefono=telefono,
            apellido="",
        )

        Citas.objects.create(
            cliente=cliente,
            empleado_id=1,  # Te asigno un empleado por defecto
            tratamiento_id=tratamiento_id,
            fecha_cita=fecha,
            hora_cita=hora,
            estado="pendiente"
        )

        return redirect("/gracias/")

    return render(request, "public/pedir_cita.html", {
        "tratamientos": tratamientos,
        "year": now().year
    })


def gracias(request):
    return render(request, "public/gracias.html", {"year": now().year})
