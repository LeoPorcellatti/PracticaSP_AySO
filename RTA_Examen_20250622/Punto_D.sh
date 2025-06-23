
cd /ansible/roles

### Creo los roles

ansible-galaxy role init Alta_Usuarios_Porcellatti
ansible-galaxy role init Sudoers_Porcellatti
ansible-galaxy role init Instala-tools_Porcellatti

### Modifico el Playbook ####
vim playbook.yml 

# ---
# - hosts: testing
#   become: true
#   tasks:
#     - include_role:
#         name: 2PRecuperatorio
#     - include_role:
#         name: Alta_Usuarios_Porcellatti
#     - include_role:
#         name: Sudoers_Porcellatti
#     - include_role:
#         name: Instala-tools_Porcellatti
#     - name: "Otra tarea"
#       debug:
#         msg: "Despues de la ejecucion del rol"



### Modifico las Task de 2PRecuperatorio ###
cd /roles/2PRecuperatorio/tasks
vim main.yml

---
# tasks file for 2PRecuperatorio

- name: "Rol: 2PRecuperatorio"
  debug:
      msg: "Inicio de tareas dentro del Rol: 2PRecuperatorio"

- name: "Crear directorio tmp/alumno"
  file:
    path: /tmp/alumno
    state: directory
    mode: '0755'

- name: "Crear archivo datos.txt con datos"
  copy:
    dest: /tmp/alumno/datos.txt
    content: | 
      Nombre: Leonardo Porcellatti
      Division: 318
      Fecha: {{ '%Y-%m-%d' | strftime }}
      -----------------------------
      Distribucion: {{ ansible_distribution }}
      Cantidad de Cores: {{ ansible_processor_vcpus }}

- name: "Aviso de exito"
  debug:
    msg: "Archivo creado"

### Modifico las task de Alta_Usuarios_Porcellatti ###
cd /roles/Alta_Usuarios_Porcellatti/tasks
vim main.yml

---
# tasks file for Alta_Usuarios_Porcellatti

- name: "Rol: Alta_Usuarios_Porcellatti"
  debug:
    msg: "Inicio de tareas dentro del Rol: Alta_Usuarios_Porcellatti"

- name: "Creo grupos GProfesores y GAlumnos"
  become: yes
  ansible.builtin.group:
    name: "{{ item }}"
    state: present
  with_items:
    - GProfesores
    - GAlumnos


- name: "Create a user 'Profesor' with a home directory"
  become: yes
  ansible.builtin.user:
    name: Profesor
    create_home: yes
    groups: GProfesores

- name: "Create a user 'Alumno' with a home directory"
  become: yes
  ansible.builtin.user:
  name: Alumno
  create_home: yes
  groups: GAlumnos

- name: "Aviso de exito"
  debug:
    msg: "Archivo Usuarios y Grupos creados"


### Modifico las task de Sudoers_Porcellatti ###
cd /roles/Sudoers_Porcellatti/tasks
vim main.yml

---
# tasks file for Sudoers_Porcellatti
- name: "Rol: Sudoers_Porcellatti"
  debug:
    msg: "Inicio de tareas dentro del Rol: Sudoers_Porcellatti"

- name: "Crear archivo /etc/sudoers.d/gprofesores si no existe"
  become: yes
  file:
    path: /etc/sudoers.d/gprofesores
    state: touch
    mode: '0440'

- name: "Permitir sudo sin contraseña a grupo GProfesores"
  become: yes
  lineinfile:
    path: /etc/sudoers.d/gprofesores
    state: present
    line: "%GProfesores ALL=(ALL) NOPASSWD: ALL"
    validate: 'visudo -cf %s'

- name: "Aviso de exito"
  debug:
  msg: "Sudoers modificado"

### Modifico las task de Instala-tools_Porcellatti###
cd /roles/Instala-tools_Porcellatti/tasks
vim main.yml

---
# tasks file for Instala-tools_Porcellatti

- name: "Rol: Instala-tools_Porcellatti"
  debug:
    msg: "Inicio de tareas dentro del Rol: Instala-tools_Porcellatti"

- name: "Agrego programas solicitados" 
  become: yes
  package:
    name: "{{ item }}"
    state: present
  with_items:
   - htop
   - tmux
   - tree
   - speedtest-cli

- name: "Aviso de exito"
  debug:
    msg: "Programas instalados"

### Ejecuto el en ansible ###
ansible-playbook -i inventory/hosts playbook.yml

