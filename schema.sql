-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : localhost:8889
-- Généré le : jeu. 11 déc. 2025 à 07:52
-- Version du serveur : 8.0.40
-- Version de PHP : 8.3.14

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `bdrando`
--

DELIMITER $$
--
-- Procédures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_stats_participations_par_randonnee` ()   BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_id_rando INT;
    DECLARE v_nom_rando VARCHAR(255);
    DECLARE v_nb_part INT;

    DECLARE cur_rando CURSOR FOR
        SELECT id_randonnee, nom FROM randonnee;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    CREATE TEMPORARY TABLE IF NOT EXISTS tmp_stats_rando (
        id_randonnee INT,
        nom_randonnee VARCHAR(255),
        nb_participations INT
    );
    TRUNCATE TABLE tmp_stats_rando;

    OPEN cur_rando;

    read_loop: LOOP
        FETCH cur_rando INTO v_id_rando, v_nom_rando;
        IF done = 1 THEN
            LEAVE read_loop;
        END IF;

        SELECT COUNT(*)
        INTO v_nb_part
        FROM participation
        WHERE id_randonnee = v_id_rando;

        INSERT INTO tmp_stats_rando(id_randonnee, nom_randonnee, nb_participations)
        VALUES (v_id_rando, v_nom_rando, v_nb_part);
    END LOOP;

    CLOSE cur_rando;

    SELECT * FROM tmp_stats_rando;
END$$

--
-- Fonctions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_moyenne_note_randonnee` (`p_id_randonnee` INT) RETURNS DECIMAL(3,2) DETERMINISTIC READS SQL DATA BEGIN
    DECLARE v_moy DECIMAL(3,2);

    SELECT AVG(note)
    INTO v_moy
    FROM participation
    WHERE id_randonnee = p_id_randonnee
      AND note IS NOT NULL;

    RETURN v_moy;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `equipement`
--

CREATE TABLE `equipement` (
  `id_equipement` int NOT NULL,
  `nom` varchar(100) NOT NULL,
  `description` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `equipement`
--

INSERT INTO `equipement` (`id_equipement`, `nom`, `description`) VALUES
(1, 'Chaussures de randonnée', 'Chaussures adaptées aux terrains accidentés'),
(2, 'Bâtons de marche', 'Permettent une meilleure stabilité'),
(3, 'Gourde 1L', 'Pour rester hydraté'),
(4, 'Lampe frontale', 'Utile au lever et coucher du soleil');

-- --------------------------------------------------------

--
-- Structure de la table `equipement_conseille`
--

CREATE TABLE `equipement_conseille` (
  `id_randonnee` int NOT NULL,
  `id_equipement` int NOT NULL,
  `obligatoire` tinyint(1) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `equipement_conseille`
--

INSERT INTO `equipement_conseille` (`id_randonnee`, `id_equipement`, `obligatoire`) VALUES
(1, 1, 1),
(1, 3, 1),
(3, 2, 0),
(3, 3, 1),
(6, 4, 1),
(7, 1, 1);

-- --------------------------------------------------------

--
-- Structure de la table `etape`
--

CREATE TABLE `etape` (
  `id_randonnee` int NOT NULL,
  `id_point` int NOT NULL,
  `ordre` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `etape`
--

INSERT INTO `etape` (`id_randonnee`, `id_point`, `ordre`) VALUES
(1, 1, 1),
(1, 5, 2),
(1, 8, 3),
(2, 3, 1),
(2, 4, 2),
(3, 5, 2),
(3, 6, 1),
(6, 7, 2),
(6, 9, 1),
(7, 10, 1);

-- --------------------------------------------------------

--
-- Structure de la table `participation`
--

CREATE TABLE `participation` (
  `id_participation` int NOT NULL,
  `id_randonneur` int NOT NULL,
  `id_randonnee` int NOT NULL,
  `date_realisation` date NOT NULL,
  `temps_realise` time NOT NULL,
  `commentaire` text NOT NULL,
  `note` tinyint DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `participation`
--

INSERT INTO `participation` (`id_participation`, `id_randonneur`, `id_randonnee`, `date_realisation`, `temps_realise`, `commentaire`, `note`) VALUES
(1, 1, 1, '2024-05-12', '03:20:00', 'Belle boucle, météo parfaite', 4),
(2, 2, 3, '2024-06-10', '04:40:00', 'Assez difficile mais superbe vue', 5),
(3, 3, 2, '2024-03-05', '02:15:00', 'Simple et agréable', 4),
(4, 4, 4, '2024-04-18', '01:05:00', 'Cascade magnifique', 4),
(5, 5, 7, '2024-07-01', '03:55:00', 'Montée exigeante', 5),
(6, 1, 5, '2024-05-15', '03:10:00', 'Beaucoup de vent', 3),
(7, 2, 6, '2024-08-22', '02:45:00', 'Tunnel impressionnant', 4),
(8, 3, 1, '2024-09-03', '03:50:00', 'Fatiguant mais faisable', 3),
(9, 1, 1, '2025-01-01', '03:30:00', 'Test OK', 4);

--
-- Déclencheurs `participation`
--
DELIMITER $$
CREATE TRIGGER `trg_verif_note_participation` BEFORE INSERT ON `participation` FOR EACH ROW BEGIN
    IF NEW.note IS NOT NULL AND (NEW.note < 1 OR NEW.note > 5) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La note doit être entre 1 et 5';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `point_interet`
--

CREATE TABLE `point_interet` (
  `id_point` int NOT NULL,
  `nom` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `type` varchar(100) NOT NULL,
  `latitude` decimal(10,7) DEFAULT NULL,
  `longitude` decimal(10,7) DEFAULT NULL,
  `altitude` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `point_interet`
--

INSERT INTO `point_interet` (`id_point`, `nom`, `description`, `type`, `latitude`, `longitude`, `altitude`) VALUES
(1, 'Belvédère Nord', 'Vue sur la vallée', 'point_de_vue', 45.1234567, 6.9876543, 850),
(2, 'Cascade Argentée', 'Cascade de 20m', 'cascade', 45.1134567, 6.9776543, 720),
(3, 'Forêt Sombre', 'Sous-bois dense', 'foret', 45.1334567, 6.9976543, 640),
(4, 'Pont Ancien', 'Pont en pierre du XVIIe siècle', 'patrimoine', 45.1434567, 6.9676543, 690),
(5, 'Roche du Loup', 'Rocher en surplomb', 'geologie', 45.1534567, 6.9576543, 900),
(6, 'Lac du Miroir', 'Lac d’altitude', 'lac', 45.1634567, 6.9476543, 1250),
(7, 'Grotte Est', 'Petite grotte naturelle', 'grotte', 45.1734567, 6.9376543, 780),
(8, 'Plateau Sud', 'Plateau ouvert venté', 'plateau', 45.1834567, 6.9276543, 980),
(9, 'Tunnel Rocheux', 'Tunnel creusé naturellement', 'tunnel', 45.1934567, 6.9176543, 650),
(10, 'Sommet du Faucon', 'Sommet culminant', 'sommet', 45.2034567, 6.9076543, 1420);

-- --------------------------------------------------------

--
-- Structure de la table `randonnee`
--

CREATE TABLE `randonnee` (
  `id_randonnee` int NOT NULL,
  `nom` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `description` text NOT NULL,
  `lieu_depart` varchar(255) NOT NULL,
  `lieu_arrivee` varchar(255) NOT NULL,
  `distance_km` decimal(5,2) DEFAULT NULL,
  `denivele_m` int NOT NULL,
  `duree_estimee` time NOT NULL,
  `type` enum('boucle','aller-retour','traversée') NOT NULL,
  `difficulte` enum('facile','moyenne','difficile') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `randonnee`
--

INSERT INTO `randonnee` (`id_randonnee`, `nom`, `description`, `lieu_depart`, `lieu_arrivee`, `distance_km`, `denivele_m`, `duree_estimee`, `type`, `difficulte`) VALUES
(1, 'Sentier des Crêtes', 'Boucle panoramique.', 'Colline Nord', 'Colline Nord', 12.50, 450, '03:30:00', 'boucle', 'moyenne'),
(2, 'Vallée Enchantée', 'Chemin forestier paisible.', 'Parking Forêt', 'Parking Forêt', 8.20, 120, '02:00:00', 'boucle', 'facile'),
(3, 'Lac du Miroir', 'Magnifique lac en altitude.', 'Village Montagne', 'Village Montagne', 15.70, 600, '04:15:00', 'aller-retour', 'difficile'),
(4, 'Cascade d’Orion', 'Petite randonnée vers une cascade.', 'Refuge Est', 'Refuge Est', 5.30, 80, '01:10:00', 'aller-retour', 'facile'),
(5, 'Plateau Ventux', 'Randonnée exposée avec vue.', 'Col Sud', 'Col Nord', 10.00, 350, '03:00:00', 'traversée', 'moyenne'),
(6, 'Gorges Souterraines', 'Passage par des tunnels naturels.', 'Entrée des Gorges', 'Sortie des Gorges', 6.70, 200, '02:40:00', 'traversée', 'difficile'),
(7, 'Sommet du Faucon', 'Ascension vers un sommet.', 'Village Est', 'Village Est', 9.40, 720, '03:50:00', 'aller-retour', 'difficile');

-- --------------------------------------------------------

--
-- Structure de la table `randonneur`
--

CREATE TABLE `randonneur` (
  `id_randonneur` int NOT NULL,
  `nom` varchar(100) NOT NULL,
  `prenom` varchar(100) NOT NULL,
  `email` varchar(255) NOT NULL,
  `date_naissance` date NOT NULL,
  `niveau` enum('debutant','intermediaire','expert') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `randonneur`
--

INSERT INTO `randonneur` (`id_randonneur`, `nom`, `prenom`, `email`, `date_naissance`, `niveau`) VALUES
(1, 'Dupont', 'Lucas', 'lucas.dupont@example.com', '1995-03-12', 'intermediaire'),
(2, 'Martin', 'Sophie', 'sophie.martin@example.com', '1988-07-25', 'expert'),
(3, 'Petit', 'Hugo', 'hugo.petit@example.com', '2001-11-02', 'debutant'),
(4, 'Leroy', 'Anna', 'anna.leroy@example.com', '1992-01-14', 'intermediaire'),
(5, 'Moreau', 'Jules', 'jules.moreau@example.com', '1985-05-30', 'expert');

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `vue_participations_detaillees`
-- (Voir ci-dessous la vue réelle)
--
CREATE TABLE `vue_participations_detaillees` (
`commentaire` text
,`date_realisation` date
,`difficulte` varchar(9)
,`id_participation` int
,`id_randonnee` int
,`id_randonneur` int
,`nom_randonnee` varchar(255)
,`nom_randonneur` varchar(100)
,`note` tinyint
,`prenom_randonneur` varchar(100)
,`temps_realise` time
);

-- --------------------------------------------------------

--
-- Structure de la vue `vue_participations_detaillees`
--
DROP TABLE IF EXISTS `vue_participations_detaillees`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vue_participations_detaillees`  AS SELECT `p`.`id_participation` AS `id_participation`, `p`.`id_randonnee` AS `id_randonnee`, (select `r`.`nom` from `randonnee` `r` where (`r`.`id_randonnee` = `p`.`id_randonnee`)) AS `nom_randonnee`, (select `r`.`difficulte` from `randonnee` `r` where (`r`.`id_randonnee` = `p`.`id_randonnee`)) AS `difficulte`, `p`.`id_randonneur` AS `id_randonneur`, (select `rr`.`nom` from `randonneur` `rr` where (`rr`.`id_randonneur` = `p`.`id_randonneur`)) AS `nom_randonneur`, (select `rr`.`prenom` from `randonneur` `rr` where (`rr`.`id_randonneur` = `p`.`id_randonneur`)) AS `prenom_randonneur`, `p`.`date_realisation` AS `date_realisation`, `p`.`temps_realise` AS `temps_realise`, `p`.`commentaire` AS `commentaire`, `p`.`note` AS `note` FROM `participation` AS `p` ;

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `equipement`
--
ALTER TABLE `equipement`
  ADD PRIMARY KEY (`id_equipement`);

--
-- Index pour la table `equipement_conseille`
--
ALTER TABLE `equipement_conseille`
  ADD PRIMARY KEY (`id_randonnee`,`id_equipement`),
  ADD KEY `id_randonneee` (`id_randonnee`),
  ADD KEY `id_equipement` (`id_equipement`);

--
-- Index pour la table `etape`
--
ALTER TABLE `etape`
  ADD PRIMARY KEY (`id_randonnee`,`id_point`),
  ADD KEY `id_randonneee` (`id_randonnee`),
  ADD KEY `id_point` (`id_point`);

--
-- Index pour la table `participation`
--
ALTER TABLE `participation`
  ADD PRIMARY KEY (`id_participation`),
  ADD UNIQUE KEY `id_participation` (`id_participation`,`id_randonneur`,`id_randonnee`,`date_realisation`),
  ADD KEY `id_randonneur` (`id_randonneur`),
  ADD KEY `id_randonnee` (`id_randonnee`);

--
-- Index pour la table `point_interet`
--
ALTER TABLE `point_interet`
  ADD PRIMARY KEY (`id_point`);

--
-- Index pour la table `randonnee`
--
ALTER TABLE `randonnee`
  ADD PRIMARY KEY (`id_randonnee`);

--
-- Index pour la table `randonneur`
--
ALTER TABLE `randonneur`
  ADD PRIMARY KEY (`id_randonneur`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `equipement`
--
ALTER TABLE `equipement`
  MODIFY `id_equipement` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT pour la table `etape`
--
ALTER TABLE `etape`
  MODIFY `id_randonnee` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT pour la table `participation`
--
ALTER TABLE `participation`
  MODIFY `id_participation` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT pour la table `point_interet`
--
ALTER TABLE `point_interet`
  MODIFY `id_point` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT pour la table `randonnee`
--
ALTER TABLE `randonnee`
  MODIFY `id_randonnee` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT pour la table `randonneur`
--
ALTER TABLE `randonneur`
  MODIFY `id_randonneur` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `equipement_conseille`
--
ALTER TABLE `equipement_conseille`
  ADD CONSTRAINT `equipement_conseille_ibfk_1` FOREIGN KEY (`id_randonnee`) REFERENCES `randonnee` (`id_randonnee`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `equipement_conseille_ibfk_2` FOREIGN KEY (`id_equipement`) REFERENCES `equipement` (`id_equipement`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Contraintes pour la table `etape`
--
ALTER TABLE `etape`
  ADD CONSTRAINT `etape_ibfk_2` FOREIGN KEY (`id_point`) REFERENCES `point_interet` (`id_point`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `etape_ibfk_3` FOREIGN KEY (`id_randonnee`) REFERENCES `randonnee` (`id_randonnee`) ON DELETE RESTRICT ON UPDATE RESTRICT;

DELIMITER $$
--
-- Évènements
--
CREATE DEFINER=`root`@`localhost` EVENT `ev_supprimer_anciennes_participations` ON SCHEDULE EVERY 1 DAY STARTS '2025-12-11 03:00:00' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
    DELETE FROM participation
    WHERE date_realisation < DATE_SUB(CURDATE(), INTERVAL 10 YEAR);
END$$

DELIMITER ;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
