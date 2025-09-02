const express = require('express');
const { getUsers, createUser, updateUser, deleteUser, loginUser } = require('../controllers/userController');

const router = express.Router();

// Explicit routes (avoid route chaining to rule out hidden characters causing path-to-regexp parse errors)
router.get('/', getUsers);
router.post('/', createUser);
router.put('/:id', updateUser);
router.delete('/:id', deleteUser);
router.post('/login', loginUser);

module.exports = router;