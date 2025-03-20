<?php
include('partial/header.php');
require 'database/db_connection.php';

if (!isset($_GET['sporting_id']) || !isset($_GET['club_id']) || !isset($_GET['country_id'])) {
    header('Location: index.php');
    exit;
}

$sportingId = $_GET['sporting_id'];
$clubId = $_GET['club_id'];
$countryId = $_GET['country_id'];

// Fetch sporting event details
$stmt = $pdo->prepare('
    SELECT sporting.*,
           clubs.name AS club_name,
           clubs.image AS club_logo,
           countries.name AS country_name
    FROM sporting
    LEFT JOIN countries ON sporting.country_id = countries.id
    LEFT JOIN clubs ON sporting.club_id = clubs.id
    WHERE sporting.id = ? AND sporting.club_id = ? AND sporting.country_id = ?
');
$stmt->execute([$sportingId, $clubId, $countryId]);
$sportingInfo = $stmt->fetch();

if (!$sportingInfo) {
    header('Location: index.php');
    exit;
}

// Fetch members for the selected sporting event
$stmt = $pdo->prepare('
    SELECT 
        sm.*, 
        s.title AS sporting_name, 
        s.logo AS sporting_logo, 
        c.name AS club_name, 
        c.image AS club_logo, 
        co.name AS country_name, 
        co.flag AS country_flag 
    FROM sport_members sm
    LEFT JOIN sporting s ON sm.sporting_id = s.id
    LEFT JOIN clubs c ON sm.club_id = c.id
    LEFT JOIN countries co ON sm.country_id = co.id
    WHERE sm.sporting_id = ? AND sm.club_id = ? AND sm.country_id = ?
    ORDER BY sm.name ASC
');
$stmt->execute([$sportingId, $clubId, $countryId]);
$members = $stmt->fetchAll();
?>

<div class="container mt-5">
    <div class="club-header mb-5">
        <div class="row align-items-center">
            <div class="col-md-3 text-center">
                <img src="<?= htmlspecialchars($sportingInfo['club_logo']) ?>"
                    alt="<?= htmlspecialchars($sportingInfo['club_name']) ?>"
                    class="img-fluid club-logo mb-3">
            </div>
            <div class="col-md-9">
                <h1 class="display-4"><?= htmlspecialchars($sportingInfo['club_name']) ?></h1>
                <div class="badges">
                    <span class="badge bg-secondary"><?= htmlspecialchars($sportingInfo['country_name']) ?></span>
                </div>
            </div>
        </div>
    </div>

    <div class="sporting-content">
        <article class="mb-5">
            <h2 class="mb-4"><?= htmlspecialchars($sportingInfo['title']) ?></h2>
            <div class="content-wrapper">
                <?= htmlspecialchars_decode($sportingInfo['detail_desc']) ?>
            </div>
        </article>

        <hr class="my-5">

        <h2 class="mb-4">Members</h2>

        <div class="row">
            <?php if (!empty($members)): ?>
                <?php foreach ($members as $member): ?>
                    <div class="col-md-4 mb-4">
                        <div class="card h-100 shadow-sm">
                            <div class="card-body">
                                <h5 class="card-title">
                                    <img src="<?= htmlspecialchars($member['avatar']) ?>"
                                        class="card-img-top" style="width: 50px;"
                                        alt="<?= htmlspecialchars($member['name']) ?>">
                                    <?= htmlspecialchars($member['name']) ?>
                                </h5>
                                <p class="card-text">
                                    <strong>Nationality:</strong> <?= htmlspecialchars($member['nationality']) ?>
                                    <img src="<?= htmlspecialchars($member['flag_image']) ?>"
                                        alt="<?= htmlspecialchars($member['country_name']) ?>" width="20"> <br>
                                    <strong>Number:</strong> <?= htmlspecialchars($member['number']) ?> <br>
                                    <strong>Position:</strong> <?= htmlspecialchars($member['position']) ?>
                                </p>
                            </div>
                        </div>
                    </div>
                <?php endforeach; ?>
            <?php else: ?>
                <p>No members found for this sporting club.</p>
            <?php endif; ?>
        </div>
    </div>
</div>

<style>
    .club-logo {
        max-width: 200px;
        height: auto;
        border-radius: 8px;
        box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
    }

    .sporting-content {
        background: white;
        padding: 2rem;
        border-radius: 8px;
        box-shadow: 0 2px 15px rgba(0, 0, 0, 0.1);
    }

    .sporting-content h2 {
        color: #2c3e50;
        border-bottom: 3px solid #3498db;
        padding-bottom: 0.5rem;
        margin-bottom: 1.5rem;
    }

    .sporting-content p {
        font-size: 1.1rem;
        line-height: 1.8;
        color: #34495e;
    }

    .badge {
        font-size: 1.1rem;
        margin-right: 0.5rem;
        padding: 0.5em 1em;
    }
</style>

<?php include('partial/footer.php'); ?>
