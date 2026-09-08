from app.db.session import SessionLocal, engine, Base
from app.models import User, Task, Notification, Device, Reminder, RecurringTask
from app.core.security import hash_password
from app.core.logging import logger


def seed_default_users():
    try:
        # Create database tables if they do not exist
        Base.metadata.create_all(bind=engine)

        db = SessionLocal()
        try:
            # Seed Admin User
            admin = db.query(User).filter(User.email == "admin@botmartz.ai").first()
            if not admin:
                admin_user = User(
                    name="BOTMARTZ Admin",
                    email="admin@botmartz.ai",
                    hashed_password=hash_password("AdminPassword123!"),
                    timezone="Asia/Kolkata"
                )
                db.add(admin_user)
                logger.info("Seeded default admin user: admin@botmartz.ai / AdminPassword123!")

            # Seed Demo User
            demo = db.query(User).filter(User.email == "demo@botmartz.ai").first()
            if not demo:
                demo_user = User(
                    name="Demo User",
                    email="demo@botmartz.ai",
                    hashed_password=hash_password("DemoPassword123!"),
                    timezone="UTC"
                )
                db.add(demo_user)
                logger.info("Seeded default demo user: demo@botmartz.ai / DemoPassword123!")

            db.commit()
        finally:
            db.close()
    except Exception as e:
        logger.error(f"Error seeding default users: {e}")
