<?php
$title = "Créer un compte";
include_once "./util/header.inc.php";
require_once "./util/config.inc.php";

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        // 收集用户输入数据
        $nom = trim($_POST['nom']);
        $prenom = trim($_POST['prenom']);
        $sexe = $_POST['sexe'];
        $email = trim($_POST['email']);
        $password = trim($_POST['password']);
        $confirm_password = trim($_POST['confirm_password']);

        // 检查是否为空
        if (empty($nom) || empty($prenom) || empty($email) || empty($password)) {
            throw new Exception("Tous les champs obligatoires doivent être remplis.");
        }

        // 检查邮箱格式
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            throw new Exception("Adresse email invalide.");
        }

        // 检查密码是否一致
        if ($password !== $confirm_password) {
            throw new Exception("Les mots de passe ne correspondent pas.");
        }

        // 检查邮箱是否已存在
        $stmt = $pdo->prepare("SELECT COUNT(*) FROM personne WHERE email = :email");
        $stmt->execute([':email' => $email]);
        if ($stmt->fetchColumn() > 0) {
            throw new Exception("Cet email est déjà utilisé.");
        }

        // 哈希密码
        $hashed_password = password_hash($password, PASSWORD_DEFAULT);

        // 获取下一个 id_personne
        $stmt_max_id = $pdo->query("SELECT COALESCE(MAX(id_personne), 0) + 1 AS next_id FROM personne");
        $next_id = $stmt_max_id->fetch(PDO::FETCH_ASSOC)['next_id'];

        // 生成登录名
        $p_login = strtolower($prenom) . '.' . strtolower($nom);

        // 插入数据到 personne 表
        $stmt_insert = $pdo->prepare("
            INSERT INTO personne (id_personne, nom, prenom, sexe, p_login, p_mdp, email)
            VALUES (:id_personne, :nom, :prenom, :sexe, :p_login, :p_mdp, :email)
        ");
        $stmt_insert->execute([
            ':id_personne' => $next_id,
            ':nom' => $nom,
            ':prenom' => $prenom,
            ':sexe' => $sexe,
            ':p_login' => $p_login,
            ':p_mdp' => $hashed_password,
            ':email' => $email
        ]);

        // 注册成功后重定向到创建 client 页面
        header("Location: createClient.php?id_personne=$next_id");
        exit;

    } catch (Exception $e) {
        // 捕获异常并设置错误消息
        $error_message = $e->getMessage();
    }
}
?>

    <h1>Créer un compte</h1>

    <!-- 显示错误或成功消息 -->
<?php if (!empty($error_message)): ?>
    <p style="color: red;"><?php echo htmlspecialchars($error_message); ?></p>
<?php endif; ?>

    <!-- 注册表单 -->
    <form method="POST" action="createAccount.php">
        <label for="nom">Nom : *</label>
        <input type="text" name="nom" id="nom" required>

        <label for="prenom">Prénom : *</label>
        <input type="text" name="prenom" id="prenom" required>

        <label for="sexe">Sexe :</label>
        <select name="sexe" id="sexe">
            <option value="H">Homme</option>
            <option value="F">Femme</option>
        </select>

        <label for="email">Email : *</label>
        <input type="email" name="email" id="email" required>

        <label for="password">Mot de passe : *</label>
        <input type="password" name="password" id="password" required>

        <label for="confirm_password">Confirmer le mot de passe : *</label>
        <input type="password" name="confirm_password" id="confirm_password" required>

        <button type="submit">Créer un compte</button>
    </form>

    <a href="connect.php" class="back-link">Retour à la connexion</a>

<?php include_once "./util/footer.inc.php"; ?>