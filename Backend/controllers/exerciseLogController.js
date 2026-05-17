const mongoose = require("mongoose");
const exerciseLogService = require("../services/exerciseLogService");

const logExercise = async (req, res) => {
  try {
    const log = await exerciseLogService.logExercise(req.userId, req.body);
    res.status(201).json({
      success: true,
      data: log,
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      message: error.message,
    });
  }
};

const getLogs = async (req, res) => {
  try {
    const logs = await exerciseLogService.getLogs(req.userId);
    res.status(200).json({
      success: true,
      count: logs.length,
      data: logs,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

const getHistory = async (req, res) => {
  try {
    const history = await exerciseLogService.getHistory(req.userId);
    res.status(200).json({
      success: true,
      count: history.length,
      data: history,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

const deleteLog = async (req, res) => {
  try {
    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
      return res.status(400).json({ success: false, message: "Invalid log ID" });
    }
    await exerciseLogService.deleteLog(req.params.id, req.userId);
    res.status(200).json({
      success: true,
      message: "Exercise log successfully deleted",
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      message: error.message,
    });
  }
};

module.exports = {
  logExercise,
  getLogs,
  getHistory,
  deleteLog,
};
