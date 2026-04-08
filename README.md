# Hiking Database (MySQL)

> Academic project – NF16 (UTT)

## Description

This project consists of designing and implementing a relational database system for managing hiking data.

It covers both **data modeling** (ER diagram) and **advanced SQL features**, including automation, data validation, and analytical queries.

## Data Model

The database is based on an Entity-Relationship model including:

* Hikes (randonnée)
* Hikers (randonneur)
* Participation records
* Equipment
* Points of interest

### ER Diagram

<img width="1600" height="736" alt="image" src="https://github.com/user-attachments/assets/db419f3f-f7de-459c-abfc-5f2956199fc2" />


## Advanced SQL Features

This project implements several advanced MySQL objects:

### Function

* `fn_moyenne_note_randonnee`
* Computes the average rating of a hike

### Trigger

* `trg_verif_note_participation`
* Ensures that ratings are between 1 and 5

### Stored Procedure

* `sp_stats_participations_par_randonnee`
* Uses a cursor to compute participation statistics

### Event

* `ev_supprimer_anciennes_participations`
* Automatically deletes old participation records

### View

* `vue_participations_detaillees`
* Provides a detailed view combining multiple tables

## Technologies

* MySQL
* SQL
* Relational Database Design

## Project Structure

* `schema.sql` : database schema (tables, constraints)
* `advanced-objects.sql` : functions, triggers, procedures, events, views
* `uml/` : ER diagram

## How to Use

1. Create a database:

```sql
CREATE DATABASE bdrando;
USE bdrando;
```

2. Execute schema:

```sql
SOURCE schema.sql;
```

3. Execute advanced objects:

```sql
SOURCE advanced-objects.sql;
```

## Author

Jiarui Huang
