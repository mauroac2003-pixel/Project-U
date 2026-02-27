# Investigación Teórica  
## Taller de Diseño Digital – EL3313  

**Estudiantes:**  
- Navarro Acuña Mauro  
- Arce Cruz Josué  
- Arguedas Guzmán Gabriel  

**Profesor:**  
Luis G. León-Vega Ph.D  

Instituto Tecnológico de Costa Rica  
I Semestre 2026  

---

# Respuestas – Preguntas de Seguimiento de Aprendizaje

---

## 1. ¿Para qué funcionan los bloques procedurales y asignaciones bloqueantes? ¿Cómo se diferencian de los `assign`?

En Verilog existen dos formas principales de describir lógica combinacional:

### 🔹 Asignación continua (`assign`)

Se utiliza para describir directamente una ecuación lógica.

Ejemplo utilizado en nuestro diseño:

```verilog
assign c = a + b;
assign c = a - b;
assign c = a * b;
