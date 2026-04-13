from flask import Blueprint, request, jsonify
from services import (
    get_all_tasks,
    get_task_by_id,
    create_task,
    update_task,
    delete_task,
)

"""
this file defines all API endpoints related to tasks
It handles HTTP requests like: GET, POST, PUT, and DELETE

and calls the correct service function for each one.

"""
tasks_bp = Blueprint("tasks", __name__, url_prefix="/api")


@tasks_bp.route("/tasks", methods=["GET"])
def fetch_tasks():
    tasks = get_all_tasks()
    return jsonify(tasks), 200


@tasks_bp.route("/tasks/<int:task_id>", methods=["GET"])
def fetch_task(task_id):
    try:
        task = get_task_by_id(task_id)
        return jsonify(task), 200
    except LookupError as e:
        return jsonify({"error": str(e)}), 404


@tasks_bp.route("/tasks", methods=["POST"])
def add_task():
    try:
        data = request.get_json(silent=True) or {}
        new_task = create_task(data)
        return jsonify(new_task), 201
    except ValueError as e:
        return jsonify({"error": str(e)}), 400


@tasks_bp.route("/tasks/<int:task_id>", methods=["PUT"])
def edit_task(task_id):
    try:
        data = request.get_json(silent=True) or {}
        updated_task = update_task(task_id, data)
        return jsonify(updated_task), 200
    except LookupError as e:
        return jsonify({"error": str(e)}), 404
    except ValueError as e:
        return jsonify({"error": str(e)}), 400


@tasks_bp.route("/tasks/<int:task_id>", methods=["DELETE"])
def remove_task(task_id):
    try:
        result = delete_task(task_id)
        return jsonify(result), 200
    except LookupError as e:
        return jsonify({"error": str(e)}), 404
