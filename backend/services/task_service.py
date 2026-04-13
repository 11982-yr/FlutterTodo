from extensions import db
from models import Task
from utils.helpers import clean_text, validate_boolean


def get_all_tasks():
    tasks = Task.query.order_by(Task.id.desc()).all()
    return [task.to_dict() for task in tasks]


def get_task_by_id(task_id):
    task = db.session.get(Task, task_id)
    if task is None:
        raise LookupError("Task not found.")
    return task.to_dict()


def create_task(data):
    if not data:
        raise ValueError("Request body is required.")

    title = clean_text(data.get("title"))
    is_done = data.get("is_done", False)

    if not title:
        raise ValueError("Title is required.")

    validate_boolean(is_done, "is_done")

    task = Task(
        title=title,
        is_done=is_done
    )

    db.session.add(task)
    db.session.commit()

    return task.to_dict()


def update_task(task_id, data):
    if not data:
        raise ValueError("Request body is required.")

    task = db.session.get(Task, task_id)
    if task is None:
        raise LookupError("Task not found.")

    if "title" in data:
        title = clean_text(data.get("title"))
        if not title:
            raise ValueError("Title cannot be empty.")
        task.title = title

    if "is_done" in data:
        validate_boolean(data.get("is_done"), "is_done")
        task.is_done = data.get("is_done")

    db.session.commit()
    return task.to_dict()


def delete_task(task_id):
    task = db.session.get(Task, task_id)
    if task is None:
        raise LookupError("Task not found.")

    db.session.delete(task)
    db.session.commit()

    return {"message": "Task deleted successfully."}
