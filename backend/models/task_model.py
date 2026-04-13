from extensions import db

class Task(db.Model):
    __tablename__ = "tasks"

    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.Text, nullable=False)
    is_done = db.Column(db.Boolean, default=False, nullable=False)
    created_at = db.Column(
        db.DateTime,
        server_default=db.func.current_timestamp(),
        nullable=False
    )

    def to_dict(self):
        return {
            "id": self.id,
            "title": self.title,
            "is_done": self.is_done,
            "created_at": self.created_at.isoformat() if self.created_at else None
        }