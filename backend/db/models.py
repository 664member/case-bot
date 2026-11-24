from datetime import datetime

from sqlalchemy import (
    BigInteger, Boolean, DateTime, Float, ForeignKey, Integer, String, Text, UniqueConstraint,
    func,
)
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column, relationship

from db.base import Base


class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=False)
    username: Mapped[str | None] = mapped_column(String(64), nullable=True)
    first_name: Mapped[str | None] = mapped_column(String(64), nullable=True)
    role: Mapped[str] = mapped_column(String(16), default="user")
    referred_by: Mapped[int | None] = mapped_column(BigInteger, nullable=True)
    is_banned: Mapped[bool] = mapped_column(Boolean, default=False)
    banned_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    ban_reason: Mapped[str | None] = mapped_column(String(255), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())


class Season(Base):
    __tablename__ = "seasons"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    chat_id: Mapped[int] = mapped_column(BigInteger, nullable=False)
    name: Mapped[str] = mapped_column(String(128))
    status: Mapped[str] = mapped_column(String(16), default="active")
    started_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    ended_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    rules_text: Mapped[str | None] = mapped_column(Text, nullable=True)
    rules_enabled: Mapped[bool] = mapped_column(Boolean, default=True)


class UserSeasonStats(Base):
    __tablename__ = "user_season_stats"
    __table_args__ = (UniqueConstraint("season_id", "user_id", name="uq_season_user"),)

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    season_id: Mapped[int] = mapped_column(ForeignKey("seasons.id"), nullable=False, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False, index=True)
    points_balance: Mapped[int] = mapped_column(BigInteger, default=0)
    streak_days: Mapped[int] = mapped_column(Integer, default=0)
    last_daily_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    total_quality_score: Mapped[int] = mapped_column(BigInteger, default=0)
    total_cases_opened: Mapped[int] = mapped_column(Integer, default=0)
    favorite_case_id: Mapped[int | None] = mapped_column(Integer, nullable=True)
    favorite_case_name: Mapped[str | None] = mapped_column(String(64), nullable=True)
    best_drop_price: Mapped[int] = mapped_column(Integer, default=0)
    best_drop_name: Mapped[str | None] = mapped_column(String(64), nullable=True)
    stats_reset_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)


class Case(Base):
    __tablename__ = "cases"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    season_id: Mapped[int] = mapped_column(ForeignKey("seasons.id"), nullable=False, index=True)
    name: Mapped[str] = mapped_column(String(64))
    price_points: Mapped[int] = mapped_column(Integer, nullable=False)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_by: Mapped[int | None] = mapped_column(BigInteger, nullable=True)
    image_url: Mapped[str | None] = mapped_column(String(255), nullable=True)

    # NEW: лимитированный кейс
    is_limited: Mapped[bool] = mapped_column(Boolean, default=False)
    limit_attempts: Mapped[int] = mapped_column(Integer, default=0)
    limit_period_hours: Mapped[int] = mapped_column(Integer, default=24)

    items: Mapped[list["CaseItem"]] = relationship(back_populates="case", cascade="all, delete-orphan")


class CaseItem(Base):
    __tablename__ = "case_items"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    case_id: Mapped[int] = mapped_column(ForeignKey("cases.id"), nullable=False, index=True)
    name: Mapped[str] = mapped_column(String(64))
    rarity: Mapped[str] = mapped_column(String(16))
    weight: Mapped[int] = mapped_column(Integer, nullable=False)
    quality_score: Mapped[int] = mapped_column(Integer, default=1)
    point_value: Mapped[int] = mapped_column(Integer, default=0)
    image_url: Mapped[str | None] = mapped_column(String(255), nullable=True)
    deleted_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)

    case: Mapped["Case"] = relationship(back_populates="items")


class Drop(Base):
    __tablename__ = "drops"

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    season_id: Mapped[int] = mapped_column(ForeignKey("seasons.id"), nullable=False, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False, index=True)
    case_id: Mapped[int] = mapped_column(ForeignKey("cases.id"), nullable=False)
    item_id: Mapped[int] = mapped_column(ForeignKey("case_items.id"), nullable=False)
    rolled_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), index=True)

    float_value: Mapped[float | None] = mapped_column(Float, nullable=True)
    quality: Mapped[str | None] = mapped_column(String(2), nullable=True)
    is_stattrak: Mapped[bool] = mapped_column(Boolean, default=False)
    final_price: Mapped[int | None] = mapped_column(Integer, nullable=True)
    is_sold: Mapped[bool] = mapped_column(Boolean, default=False)


class PointTransaction(Base):
    __tablename__ = "point_transactions"

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    season_id: Mapped[int] = mapped_column(ForeignKey("seasons.id"), nullable=False, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False, index=True)
    amount: Mapped[int] = mapped_column(Integer, nullable=False)
    source: Mapped[str] = mapped_column(String(32))
    meta: Mapped[dict | None] = mapped_column(JSONB, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), index=True)


class TournamentTemplate(Base):
    __tablename__ = "tournament_templates"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    season_id: Mapped[int] = mapped_column(ForeignKey("seasons.id"), nullable=False, index=True)
    name: Mapped[str] = mapped_column(String(64))
    type: Mapped[str] = mapped_column(String(16))
    duration_hours: Mapped[int] = mapped_column(Integer, default=24)
    top_n: Mapped[int] = mapped_column(Integer, default=10)
    min_score: Mapped[int] = mapped_column(Integer, default=0)
    score_multiplier: Mapped[dict] = mapped_column(JSONB, default=dict)
    reward_config: Mapped[dict] = mapped_column(JSONB, default=dict)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    is_recurring: Mapped[bool] = mapped_column(Boolean, default=True)
    display_limit: Mapped[int] = mapped_column(Integer, default=10)
    nickname_max_length: Mapped[int] = mapped_column(Integer, default=15)
    leaderboard_labels: Mapped[dict] = mapped_column(JSONB, default=dict)
    cron_expression: Mapped[str | None] = mapped_column(String(64), nullable=True)
    next_start_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)


class Tournament(Base):
    __tablename__ = "tournaments"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    template_id: Mapped[int | None] = mapped_column(ForeignKey("tournament_templates.id"), nullable=True)
    season_id: Mapped[int] = mapped_column(ForeignKey("seasons.id"), index=True)
    name: Mapped[str] = mapped_column(String(64))
    starts_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    ends_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    status: Mapped[str] = mapped_column(String(16), default="scheduled")
    top_n: Mapped[int] = mapped_column(Integer, default=10)
    min_score: Mapped[int] = mapped_column(Integer, default=0)
    score_multiplier: Mapped[dict] = mapped_column(JSONB, default=dict)
    reward_config: Mapped[dict] = mapped_column(JSONB, default=dict)
    display_limit: Mapped[int] = mapped_column(Integer, default=10)
    nickname_max_length: Mapped[int] = mapped_column(Integer, default=15)
    leaderboard_labels: Mapped[dict] = mapped_column(JSONB, default=dict)
    finalized_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)


class TournamentEntry(Base):
    __tablename__ = "tournament_entries"
    __table_args__ = (UniqueConstraint("tournament_id", "user_id", name="uq_tournament_user"),)

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    tournament_id: Mapped[int] = mapped_column(ForeignKey("tournaments.id"), index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
    total_score: Mapped[int] = mapped_column(BigInteger, default=0)
    rank: Mapped[int | None] = mapped_column(Integer, nullable=True)
    reward_given: Mapped[bool] = mapped_column(Boolean, default=False)


class ManualReward(Base):
    __tablename__ = "manual_rewards"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"))
    tournament_id: Mapped[int | None] = mapped_column(ForeignKey("tournaments.id"), nullable=True)
    description: Mapped[str] = mapped_column(Text)
    status: Mapped[str] = mapped_column(String(16), default="pending")
    created_by: Mapped[int] = mapped_column(BigInteger)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    given_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)


class ActivityRewardConfig(Base):
    __tablename__ = "activity_reward_config"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    season_id: Mapped[int] = mapped_column(ForeignKey("seasons.id"), nullable=False, unique=True)

    points_comment: Mapped[int] = mapped_column(Integer, default=2)
    points_subscription: Mapped[int] = mapped_column(Integer, default=30)
    points_referral: Mapped[int] = mapped_column(Integer, default=20)

    daily_limit_comment: Mapped[int] = mapped_column(Integer, default=10)
    min_comment_length: Mapped[int] = mapped_column(Integer, default=15)
    comment_cooldown_seconds: Mapped[int] = mapped_column(Integer, default=10)
    block_duplicate_comments: Mapped[bool] = mapped_column(Boolean, default=True)

    referral_requires_action: Mapped[bool] = mapped_column(Boolean, default=True)

    quality_weight_fn: Mapped[int] = mapped_column(Integer, default=10)
    quality_weight_mw: Mapped[int] = mapped_column(Integer, default=20)
    quality_weight_ft: Mapped[int] = mapped_column(Integer, default=50)
    quality_weight_ww: Mapped[int] = mapped_column(Integer, default=15)
    quality_weight_bs: Mapped[int] = mapped_column(Integer, default=5)

    mult_fn: Mapped[float] = mapped_column(Float, default=1.45)
    mult_mw: Mapped[float] = mapped_column(Float, default=1.15)
    mult_ft: Mapped[float] = mapped_column(Float, default=0.85)
    mult_ww: Mapped[float] = mapped_column(Float, default=0.65)
    mult_bs: Mapped[float] = mapped_column(Float, default=0.5)

    stattrak_chance: Mapped[int] = mapped_column(Integer, default=10)
    stattrak_multiplier: Mapped[float] = mapped_column(Float, default=2.0)