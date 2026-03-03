"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ExamCountdownModule = void 0;
const common_1 = require("@nestjs/common");
const exam_countdown_controller_1 = require("./exam-countdown.controller");
const exam_countdown_service_1 = require("./exam-countdown.service");
let ExamCountdownModule = class ExamCountdownModule {
};
exports.ExamCountdownModule = ExamCountdownModule;
exports.ExamCountdownModule = ExamCountdownModule = __decorate([
    (0, common_1.Module)({
        controllers: [exam_countdown_controller_1.ExamCountdownController],
        providers: [exam_countdown_service_1.ExamCountdownService],
    })
], ExamCountdownModule);
//# sourceMappingURL=exam-countdown.module.js.map