const express = require('express');
const { getArticles, createArticle, updateArticle, toggleArticleStatus, getArticleByName } = require('../controllers/articleController');

const router = express.Router();

router.get('/', getArticles);
router.post('/', createArticle);
router.put('/:id', updateArticle);
router.patch('/:id/toggle', toggleArticleStatus);
router.get('/:name', getArticleByName);

module.exports = router;