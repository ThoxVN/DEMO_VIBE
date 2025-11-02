import { LightningElement } from 'lwc';

export default class ColorToggle extends LightningElement {
    isPrimary = true;

    get boxStyle() {
        const bg = this.isPrimary ? '#2e86de' : '#e74c3c'; // xanh / đỏ
        return `width: 160px; height: 80px; border-radius: 8px; background: ${bg}; box-shadow: 0 2px 6px rgba(0,0,0,0.15);`;
    }

    handleToggle() {
        this.isPrimary = !this.isPrimary;
    }
}
