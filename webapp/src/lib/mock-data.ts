import { Case, Drop, LeaderboardEntry, UserProfile } from "./types";

export const mockCases: Case[] = [
  {
    id: "neon",
    name: "Неоновый",
    price: 120,
    items: [
      { id: "1", name: "Серый болт", rarity: "Common", chance: 65.5, pointValue: 5 },
      { id: "2", name: "Синий клинок", rarity: "Rare", chance: 25.0, pointValue: 40 },
      { id: "3", name: "Пурпурный шар", rarity: "Epic", chance: 8.0, pointValue: 150 },
      { id: "4", name: "Золотой череп", rarity: "Legendary", chance: 1.5, pointValue: 600 },
    ],
  },
  {
    id: "gold",
    name: "Золотой",
    price: 300,
    items: [
      { id: "5", name: "Медный диск", rarity: "Common", chance: 50.0, pointValue: 15 },
      { id: "6", name: "Серебряный кубок", rarity: "Rare", chance: 35.0, pointValue: 80 },
      { id: "7", name: "Платиновое кольцо", rarity: "Epic", chance: 12.0, pointValue: 400 },
      { id: "8", name: "Корона", rarity: "Legendary", chance: 3.0, pointValue: 1500 },
    ],
  },
  {
    id: "starter",
    name: "Стартовый",
    price: 40,
    items: [
      { id: "9", name: "Обычный камень", rarity: "Common", chance: 80.0, pointValue: 2 },
      { id: "10", name: "Бронзовый ключ", rarity: "Rare", chance: 18.0, pointValue: 20 },
      { id: "11", name: "Изумруд", rarity: "Epic", chance: 2.0, pointValue: 100 },
    ],
  },
];

export const mockDrops: Drop[] = [
  { id: "d1", userId: 1, username: "vasya", itemName: "Золотой череп", rarity: "Legendary", caseName: "Неоновый", rolledAt: Date.now() - 5000 },
  { id: "d2", userId: 2, username: "petya", itemName: "Синий клинок", rarity: "Rare", caseName: "Неоновый", rolledAt: Date.now() - 30000 },
  { id: "d3", userId: 3, username: "kolya", itemName: "Обычный камень", rarity: "Common", caseName: "Стартовый", rolledAt: Date.now() - 60000 },
  { id: "d4", userId: 4, username: "masha", itemName: "Платиновое кольцо", rarity: "Epic", caseName: "Золотой", rolledAt: Date.now() - 120000 },
  { id: "d5", userId: 5, username: "olya", itemName: "Бронзовый ключ", rarity: "Rare", caseName: "Стартовый", rolledAt: Date.now() - 180000 },
];

export const mockLeaderboard: LeaderboardEntry[] = [
  { userId: 1, username: "vasya", score: 420, rank: 1 },
  { userId: 2, username: "petya", score: 380, rank: 2 },
  { userId: 3, username: "kolya", score: 310, rank: 3 },
  { userId: 4, username: "masha", score: 250, rank: 4 },
  { userId: 5, username: "olya", score: 190, rank: 5 },
];

export const mockProfile: UserProfile = {
  id: 123,
  username: "testuser",
  firstName: "Test",
  balance: 340,
  streak: 5,
  seasonName: "Сезон 1 — Осень 2026",
};