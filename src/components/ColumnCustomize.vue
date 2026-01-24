<!-- src/views/system/user/column-customize.vue -->
<template>
  <el-dialog
    title="自定义列"
    :visible.sync="visible"
    width="600px"
    @close="handleClose"
    class="column-customize-dialog"
  >
    <div class="dialog-content">
      <div class="tip-info">
        <i class="el-icon-info"></i>
        <span>勾选需要显示的列，拖动调整顺序</span>
      </div>

      <div class="column-list-container">
        <div
          v-for="(column, index) in columns"
          :key="column.prop || column.columnKey"
          class="column-item"
          :class="{ 'fixed-column': column.fixed }"
          :draggable="!column.fixed"
          @dragstart="handleDragStart(index)"
          @dragover.prevent="handleDragOver(index)"
          @drop="handleDrop(index)"
        >
          <div class="column-handle" v-if="!column.fixed">
            <i class="el-icon-rank"></i>
          </div>

          <el-checkbox
            v-model="column.visible"
            :disabled="column.required"
            class="column-checkbox"
          >
            {{ column.label }}
          </el-checkbox>

          <div class="column-actions">
            <el-tooltip
              v-if="column.fixed"
              content="固定列不可隐藏"
              placement="top"
            >
              <i class="el-icon-lock"></i>
            </el-tooltip>

            <el-tooltip
              v-if="column.required"
              content="必需列"
              placement="top"
            >
              <i class="el-icon-warning-outline"></i>
            </el-tooltip>

            <el-tag
              v-if="column.fixed === 'left'"
              size="mini"
              type="info"
            >
              左固定
            </el-tag>

            <el-tag
              v-if="column.fixed === 'right'"
              size="mini"
              type="info"
            >
              右固定
            </el-tag>
          </div>
        </div>
      </div>

      <div class="preview-tip">
        <el-alert
          title="提示"
          type="info"
          :closable="false"
          show-icon
        >
          <div>调整后请刷新表格查看效果</div>
        </el-alert>
      </div>
    </div>

    <div slot="footer" class="dialog-footer">
      <el-button @click="handleReset">重置默认</el-button>
      <el-button @click="handleClose">取消</el-button>
      <el-button type="primary" @click="handleConfirm">确认</el-button>
    </div>
  </el-dialog>
</template>

<script>
export default {
  name: 'ColumnCustomize',

  props: {
    // 原始列配置
    columns: {
      type: Array,
      required: true
    },
    // 是否显示弹窗
    visible: {
      type: Boolean,
      default: false
    }
  },

  data() {
    return {
      localColumns: [],
      dragIndex: null,
      dropIndex: null
    };
  },

  watch: {
    columns: {
      immediate: true,
      handler(newVal) {
        this.localColumns = JSON.parse(JSON.stringify(newVal));
        // 为每列添加visible属性
        this.localColumns.forEach(col => {
          if (col.visible === undefined) {
            col.visible = !col.hidden;
          }
          // 标记必需列（selection、action等）
          if (col.type === 'selection' || col.columnKey === 'action') {
            col.required = true;
            col.visible = true;
          }
        });
      }
    },

    visible(val) {
      if (val) {
        // 打开弹窗时重置为原始数据
        this.localColumns = JSON.parse(JSON.stringify(this.columns));
      }
    }
  },

  methods: {
    /* 处理拖拽开始 */
    handleDragStart(index) {
      this.dragIndex = index;
    },

    /* 处理拖拽经过 */
    handleDragOver(index) {
      this.dropIndex = index;
    },

    /* 处理放置 */
    handleDrop(index) {
      if (this.dragIndex === null || this.dragIndex === index) return;

      const dragItem = this.localColumns[this.dragIndex];
      this.localColumns.splice(this.dragIndex, 1);
      this.localColumns.splice(index, 0, dragItem);

      this.dragIndex = null;
      this.dropIndex = null;
    },

    /* 重置为默认 */
    handleReset() {
      this.$confirm('确定要重置为默认列设置吗？', '提示', {
        type: 'warning'
      }).then(() => {
        const defaultColumns = this.getDefaultColumns();
        this.localColumns = JSON.parse(JSON.stringify(defaultColumns));
        this.$message.success('已重置为默认设置');
      });
    },

    /* 获取默认列配置 */
    getDefaultColumns() {
      // 这里可以定义默认的列配置
      return [
        {
          columnKey: "selection",
          type: "selection",
          width: 55,
          align: "center",
          fixed: "left",
          label: "选择",
          visible: true,
          required: true
        },
        {
          prop: "avatar",
          label: "用户信息",
          align: "left",
          minWidth: 200,
          slot: "avatar",
          fixed: "left",
          visible: true
        },
        {
          prop: "username",
          label: "账号信息",
          align: "left",
          minWidth: 150,
          slot: "username",
          visible: true
        },
        {
          prop: "genderName",
          label: "性别",
          align: "center",
          width: 100,
          slot: "gender",
          visible: true
        },
        {
          prop: "contact",
          label: "联系方式",
          align: "left",
          minWidth: 180,
          slot: "contact",
          visible: true
        },
        {
          columnKey: "roles",
          label: "角色",
          align: "left",
          minWidth: 200,
          slot: "roles",
          visible: true
        },
        {
          prop: "intro",
          label: "个人简介",
          align: "left",
          minWidth: 150,
          showOverflowTooltip: true,
          visible: false
        },
        {
          prop: "status",
          label: "状态",
          align: "center",
          width: 100,
          slot: "status",
          visible: true
        },
        {
          prop: "createdAt",
          label: "创建时间",
          align: "center",
          width: 180,
          visible: true
        },
        {
          prop: "updatedAt",
          label: "更新时间",
          align: "center",
          width: 180,
          visible: false
        },
        {
          columnKey: "action",
          label: "操作",
          width: 220,
          align: "center",
          fixed: "right",
          slot: "action",
          visible: true,
          required: true
        }
      ];
    },

    /* 确认保存 */
    handleConfirm() {
      // 过滤出visible为true的列
      const visibleColumns = this.localColumns.filter(col => col.visible);

      // 更新父组件列配置
      this.$emit('update:columns', visibleColumns);

      // 保存到本地存储
      this.saveToLocalStorage(visibleColumns);

      this.$emit('update:visible', false);
      this.$message.success('列配置已保存');
    },

    /* 保存到本地存储 */
    saveToLocalStorage(columns) {
      try {
        const config = {
          timestamp: new Date().getTime(),
          columns: columns.map(col => ({
            prop: col.prop,
            label: col.label,
            visible: col.visible,
            width: col.width,
            minWidth: col.minWidth,
            fixed: col.fixed,
            sort: this.localColumns.indexOf(col)
          }))
        };
        localStorage.setItem('user_table_columns', JSON.stringify(config));
      } catch (e) {
        console.error('保存列配置失败:', e);
      }
    },

    /* 关闭弹窗 */
    handleClose() {
      this.$emit('update:visible', false);
    }
  }
};
</script>

<style scoped>
.column-customize-dialog ::v-deep .el-dialog__body {
  padding: 20px;
}

.dialog-content {
  max-height: 500px;
  overflow-y: auto;
}

.tip-info {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 16px;
  background: #f0f9ff;
  border-radius: 4px;
  margin-bottom: 20px;
  border-left: 4px solid #1890ff;
}

.tip-info i {
  color: #1890ff;
  font-size: 16px;
}

.tip-info span {
  color: #606266;
  font-size: 14px;
}

.column-list-container {
  margin: 20px 0;
}

.column-item {
  display: flex;
  align-items: center;
  padding: 12px 16px;
  margin-bottom: 8px;
  background: #f8f9fa;
  border-radius: 6px;
  border: 1px solid #e8e8e8;
  transition: all 0.3s;
  cursor: move;
}

.column-item:hover {
  background: #e6f7ff;
  border-color: #91d5ff;
}

.column-item.fixed-column {
  background: #fff7e6;
  border-color: #ffd591;
  cursor: not-allowed;
}

.column-handle {
  margin-right: 12px;
  color: #c0c4cc;
  cursor: grab;
}

.column-handle:active {
  cursor: grabbing;
}

.column-checkbox {
  flex: 1;
  margin-right: 12px;
}

.column-checkbox ::v-deep .el-checkbox__label {
  font-weight: 500;
}

.column-actions {
  display: flex;
  align-items: center;
  gap: 8px;
}

.column-actions i {
  color: #909399;
  font-size: 14px;
}

.preview-tip {
  margin-top: 20px;
}

.dialog-footer {
  text-align: right;
}

/* 拖拽样式 */
.column-item.drag-over {
  background: #d6e4ff;
  border-color: #85a5ff;
  transform: translateY(2px);
}

/* 响应式 */
@media (max-width: 768px) {
  .column-customize-dialog ::v-deep .el-dialog {
    width: 90% !important;
  }

  .column-item {
    flex-wrap: wrap;
  }

  .column-actions {
    margin-top: 8px;
    width: 100%;
  }
}
</style>
